import 'package:flutter/material.dart';
import 'package:gold/const/constants.dart';
import 'package:gold/model/model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class DetailsScreen extends StatelessWidget {
  final String title;
  final dynamic item;
  final String type;

  DetailsScreen({
    Key? key,
    required this.title,
    required this.item,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Column(
          children: [
            // بخش هدر ثابت
            Container(
              height: 180,
              color: _getHeaderColor(),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // محتوای هدر
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40), // فضا برای نوار وضعیت
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.share,
                                color: Colors.white,
                              ),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.bookmark_border,
                                color: Colors.white,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'YekanBakh',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // کارت اصلی که روی هدر و محتوا قرار می‌گیرد
                  Positioned(
                    bottom: -60, // نصف ارتفاع کارت
                    left: 16,
                    right: 16,
                    child: _buildMainInfoCard(),
                  ),
                ],
              ),
            ),

            // فضای خالی به اندازه نصف ارتفاع کارت اصلی
            const SizedBox(height: 60),

            // محتوای اصلی با اسکرول
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (type == 'currency') _buildCurrencyDetails(),
                    if (type == 'gold') _buildGoldDetails(),
                    if (type == 'crypto') _buildCryptoDetails(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (type) {
      case 'currency':
        return Icons.currency_exchange;
      case 'gold':
        return Icons.monetization_on;
      case 'crypto':
        return Icons.currency_bitcoin;
      default:
        return Icons.info;
    }
  }

  // کش کردن رنگ‌ها برای جلوگیری از محاسبه مجدد
  final Map<String, Color> _colorCache = {};

  Color _getHeaderColor() {
    if (_colorCache.containsKey(type)) {
      return _colorCache[type]!;
    }

    Color color;
    switch (type) {
      case 'currency':
        color = Colors.blue;
        break;
      case 'gold':
        color = Colors.amber.shade700;
        break;
      case 'crypto':
        color = Colors.purple;
        break;
      default:
        color = Colors.teal;
    }

    _colorCache[type] = color;
    return color;
  }

  Widget _buildMainInfoCard() {
    final dynamic currentItem = item;
    final double changePercent =
        double.tryParse(
          currentItem.changePercent.toString().replaceAll('%', ''),
        ) ??
        0.0;
    final bool isPositive = changePercent >= 0;
    final Color changeColor = isPositive ? Colors.green : Colors.red;
    final IconData changeIcon =
        isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      height: 120, // ارتفاع ثابت
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, 4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Hero(
              tag: 'icon-${currentItem.name}',
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getHeaderColor().withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getTypeIcon(), size: 32, color: _getHeaderColor()),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentItem.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Constants.blackColor,
                      fontFamily: 'YekanBakh',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getPriceWithUnit(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IranSans',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: changeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(changeIcon, color: changeColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${changePercent.abs().toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: changeColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IranSans',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPriceWithUnit() {
    final dynamic currentItem = item;
    String price = _formatNumber(currentItem.price);

    switch (type) {
      case 'currency':
        final currency = item as Currency;
        return '$price ${currency.unit}';
      case 'gold':
        return '$price تومان';
      case 'crypto':
        return '$price دلار';
      default:
        return price;
    }
  }

  Widget _buildCurrencyDetails() {
    final currency = item as Currency;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('اطلاعات ارز'),
        _buildInfoCard('نام ارز', currency.name, Icons.label),
        _buildInfoCard(
          'قیمت فعلی',
          '${_formatNumber(currency.price)} ${currency.unit}',
          Icons.attach_money,
        ),
        _buildInfoCard('تغییرات', '${currency.changeValue}', Icons.trending_up),
        _buildInfoCard(
          'درصد تغییرات',
          '${currency.changePercent}%',
          Icons.percent,
        ),

        const SizedBox(height: 24),
        _buildSectionTitle('اطلاعات بروزرسانی'),
        _buildInfoCard(
          'تاریخ بروزرسانی',
          currency.date ?? 'امروز',
          Icons.calendar_today,
        ),
        _buildInfoCard('زمان بروزرسانی', currency.time, Icons.access_time),

        const SizedBox(height: 24),
        _buildRecentPrices(),

        const SizedBox(height: 24),
        _buildPriceChart(),
      ],
    );
  }

  Widget _buildGoldDetails() {
    final gold = item as Currency;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('اطلاعات طلا'),
        _buildInfoCard('نام', gold.name, Icons.label),
        _buildInfoCard(
          'قیمت فعلی',
          '${_formatNumber(gold.price)} تومان',
          Icons.monetization_on,
        ),
        _buildInfoCard('تغییرات', '${gold.changeValue}', Icons.trending_up),
        _buildInfoCard('درصد تغییرات', '${gold.changePercent}%', Icons.percent),

        const SizedBox(height: 24),
        _buildSectionTitle('اطلاعات بروزرسانی'),
        _buildInfoCard(
          'تاریخ بروزرسانی',
          gold.date ?? 'امروز',
          Icons.calendar_today,
        ),
        _buildInfoCard('زمان بروزرسانی', gold.time, Icons.access_time),

        const SizedBox(height: 24),
        _buildRecentPrices(),

        const SizedBox(height: 24),
        _buildPriceChart(),
      ],
    );
  }

  Widget _buildCryptoDetails() {
    final crypto = item as Currency;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('اطلاعات ارز دیجیتال'),
        _buildInfoCard('نام ارز', crypto.name, Icons.label),
        _buildInfoCard(
          'قیمت فعلی',
          '${_formatNumber(crypto.price)} دلار',
          Icons.currency_bitcoin,
        ),
        _buildInfoCard('تغییرات', '${crypto.changeValue}', Icons.trending_up),
        _buildInfoCard(
          'درصد تغییرات',
          '${crypto.changePercent}%',
          Icons.percent,
        ),

        const SizedBox(height: 24),
        _buildSectionTitle('اطلاعات بروزرسانی'),
        _buildInfoCard(
          'تاریخ بروزرسانی',
          crypto.date ?? 'امروز',
          Icons.calendar_today,
        ),
        _buildInfoCard('زمان بروزرسانی', crypto.time, Icons.access_time),

        const SizedBox(height: 24),
        _buildRecentPrices(),

        const SizedBox(height: 24),
        _buildPriceChart(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16.0,
        right: 16.0,
        left: 16.0,
        top: 30.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: _getHeaderColor(),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Constants.blackColor,
              fontFamily: 'YekanBakh',
            ),
            textAlign: TextAlign.right,
          ),
          const Spacer(),
          Container(height: 1, width: 100, color: Colors.grey.withOpacity(0.2)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(2, 2),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getHeaderColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _getHeaderColor().withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 22, color: _getHeaderColor()),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          color: Constants.blackColor.withOpacity(0.6),
                          fontFamily: 'YekanBakh',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Constants.blackColor,
                          fontFamily: 'YekanBakh',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceChart() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(2, 2),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'نمودار قیمت',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Constants.blackColor,
                        fontFamily: 'YekanBakh',
                      ),
                    ),
                    Row(
                      children: [
                        _buildChartPeriodButton('روزانه', true),
                        const SizedBox(width: 8),
                        _buildChartPeriodButton('هفتگی', false),
                        const SizedBox(width: 8),
                        _buildChartPeriodButton('ماهانه', false),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _getHeaderColor().withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.bar_chart,
                            size: 50,
                            color: _getHeaderColor(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'نمودار به زودی اضافه خواهد شد',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontFamily: 'YekanBakh',
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartPeriodButton(String text, bool isActive) {
    return InkWell(
      onTap: () {
        // تغییر دوره زمانی
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _getHeaderColor() : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: _getHeaderColor().withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade700,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'YekanBakh',
          ),
        ),
      ),
    );
  }

  // تابع کمکی برای فرمت‌بندی اعداد با جداکننده هزارگان
  String _formatNumber(dynamic number) {
    // تبدیل به رشته
    String numStr = number.toString();

    // اگر عدد نیست، همان رشته را برگردان
    if (numStr.isEmpty) return numStr;

    try {
      // تلاش برای تبدیل به عدد
      double? num = double.tryParse(numStr.replaceAll(',', ''));
      if (num == null) return numStr;

      // اگر عدد صحیح است
      if (num == num.toInt()) {
        return num.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
      }

      // اگر اعشاری است
      return num.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    } catch (e) {
      return numStr;
    }
  }

  // تابع نمایش قیمت‌های اخیر
  Widget _buildRecentPrices() {
    // تبدیل قیمت به عدد
    double numericPrice = 0.0;
    try {
      if (item.price is int) {
        numericPrice = (item.price as int).toDouble();
      } else if (item.price is double) {
        numericPrice = item.price;
      } else {
        numericPrice =
            double.tryParse(item.price.toString().replaceAll(',', '')) ?? 0.0;
      }
    } catch (e) {
      // در صورت خطا، از مقدار پیش‌فرض استفاده می‌کنیم
      print('Error parsing price: $e');
    }

    // داده‌های نمونه برای قیمت‌های اخیر با مقادیر ثابت برای اطمینان
    final List<Map<String, dynamic>> recentPrices = [
      {'date': 'امروز', 'price': numericPrice, 'change': 0.0},
      {
        'date': 'دیروز',
        'price': numericPrice > 0 ? numericPrice * 0.98 : 0.0,
        'change': -2.0,
      },
      {
        'date': 'دو روز قبل',
        'price': numericPrice > 0 ? numericPrice * 0.97 : 0.0,
        'change': -3.0,
      },
      {
        'date': 'سه روز قبل',
        'price': numericPrice > 0 ? numericPrice * 1.01 : 0.0,
        'change': 1.0,
      },
      {
        'date': 'چهار روز قبل',
        'price': numericPrice > 0 ? numericPrice * 0.99 : 0.0,
        'change': -1.0,
      },
    ];

    String priceUnit = '';
    switch (type) {
      case 'currency':
        final currency = item as Currency;
        priceUnit = currency.unit;
        break;
      case 'gold':
        priceUnit = 'تومان';
        break;
      case 'crypto':
        priceUnit = 'دلار';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('قیمت‌های اخیر'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(2, 2),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentPrices.length,
            separatorBuilder:
                (context, index) => Divider(
                  color: Colors.grey.withOpacity(0.1),
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
            itemBuilder: (context, index) {
              final price = recentPrices[index];
              final bool isPositive = (price['change'] as double) >= 0;
              final Color changeColor = isPositive ? Colors.green : Colors.red;
              final IconData changeIcon =
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            index == 0
                                ? _getHeaderColor().withOpacity(0.1)
                                : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          (index + 1).toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                index == 0
                                    ? _getHeaderColor()
                                    : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            price['date'],
                            style: TextStyle(
                              color: Constants.blackColor.withOpacity(0.7),
                              fontFamily: 'YekanBakh',
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatNumber(price['price'])} $priceUnit',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'IranSans',
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: changeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(changeIcon, color: changeColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${price['change'].abs()}%',
                            style: TextStyle(
                              color: changeColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'IranSans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
