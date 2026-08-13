import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/resident_provider.dart';

class InviteVisitorDialog extends StatefulWidget {
  final String userId;
  final String flatNumber;
  final String hostName;

  const InviteVisitorDialog({
    super.key,
    required this.userId,
    required this.flatNumber,
    required this.hostName,
  });

  @override
  State<InviteVisitorDialog> createState() => _InviteVisitorDialogState();
}

class _InviteVisitorDialogState extends State<InviteVisitorDialog> {
  static final Map<String, _DialogBrandInfo> _dialogBrandMapping = {
    'swiggy': _DialogBrandInfo(
      domain: 'swiggy.com',
      primaryColor: const Color(0xFFFC8019),
      fallbackTextColor: Colors.white,
    ),
    'zomato': _DialogBrandInfo(
      domain: 'zomato.com',
      primaryColor: const Color(0xFFCB202D),
      fallbackTextColor: Colors.white,
    ),
    'amazon': _DialogBrandInfo(
      domain: 'amazon.in',
      primaryColor: const Color(0xFF232F3E),
      fallbackTextColor: const Color(0xFFFF9900),
    ),
    'uber': _DialogBrandInfo(
      domain: 'uber.com',
      primaryColor: Colors.black,
      fallbackTextColor: Colors.white,
    ),
    'flipkart': _DialogBrandInfo(
      domain: 'flipkart.com',
      primaryColor: const Color(0xFF2874F0),
      fallbackTextColor: const Color(0xFFFFE11B),
    ),
    'dunzo': _DialogBrandInfo(
      domain: 'dunzo.com',
      primaryColor: const Color(0xFF00E676),
      fallbackTextColor: Colors.black,
    ),
    'urban company': _DialogBrandInfo(
      domain: 'urbancompany.com',
      primaryColor: Colors.black,
      fallbackTextColor: Colors.white,
    ),
    'dhl': _DialogBrandInfo(
      domain: 'dhl.com',
      primaryColor: const Color(0xFFFFCC00),
      fallbackTextColor: const Color(0xFFD40511),
    ),
    'bluedart': _DialogBrandInfo(
      domain: 'bluedart.com',
      primaryColor: const Color(0xFF003399),
      fallbackTextColor: const Color(0xFFFFCC00),
    ),
    'fedex': _DialogBrandInfo(
      domain: 'fedex.com',
      primaryColor: const Color(0xFFFF6200),
      fallbackTextColor: Colors.white,
    ),
    'blinkit': _DialogBrandInfo(
      domain: 'blinkit.com',
      primaryColor: const Color(0xFFF7EC13),
      fallbackTextColor: Colors.black,
    ),
    'blink it': _DialogBrandInfo(
      domain: 'blinkit.com',
      primaryColor: const Color(0xFFF7EC13),
      fallbackTextColor: Colors.black,
    ),
    'ola': _DialogBrandInfo(
      domain: 'olacabs.com',
      primaryColor: const Color(0xFFC6DB1A),
      fallbackTextColor: Colors.black,
    ),
    'ola cabs': _DialogBrandInfo(
      domain: 'olacabs.com',
      primaryColor: const Color(0xFFC6DB1A),
      fallbackTextColor: Colors.black,
    ),
    'rapido': _DialogBrandInfo(
      domain: 'rapido.bike',
      primaryColor: const Color(0xFFFFDD00),
      fallbackTextColor: Colors.black,
    ),
  };

  String? _detectDialogBrandKey(String name) {
    final lowerName = name.toLowerCase();
    for (final key in _dialogBrandMapping.keys) {
      if (lowerName.contains(key)) {
        return key;
      }
    }
    return null;
  }

  Widget _buildBrandLogoWidget(String brandName, IconData defaultIcon, Color defaultColor) {
    final brandKey = _detectDialogBrandKey(brandName);
    if (brandKey == null) {
      return CircleAvatar(
        backgroundColor: defaultColor.withAlpha(20),
        radius: 18,
        child: Icon(defaultIcon, color: defaultColor, size: 18),
      );
    }

    final brand = _dialogBrandMapping[brandKey]!;
    
    Widget vectorFallback;
    switch (brandKey.toLowerCase()) {
      case 'swiggy':
        vectorFallback = const Center(
          child: Text(
            'S',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              fontStyle: FontStyle.italic,
              fontFamily: 'Outfit',
            ),
          ),
        );
        break;
      case 'zomato':
        vectorFallback = const Center(
          child: Icon(
            Icons.favorite_rounded,
            color: Colors.white,
            size: 16,
          ),
        );
        break;
      case 'amazon':
        vectorFallback = const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'a',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  height: 1.0,
                  fontFamily: 'Outfit',
                ),
              ),
              Icon(
                Icons.subdirectory_arrow_right_rounded,
                color: Color(0xFFFF9900),
                size: 8,
              ),
            ],
          ),
        );
        break;
      case 'uber':
        vectorFallback = const Center(
          child: Text(
            'U',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'Outfit',
              letterSpacing: -0.5,
            ),
          ),
        );
        break;
      case 'flipkart':
        vectorFallback = const Center(
          child: Icon(
            Icons.shopping_cart_rounded,
            color: Color(0xFFFFE11B),
            size: 14,
          ),
        );
        break;
      case 'dunzo':
        vectorFallback = const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'd',
                style: TextStyle(
                  color: Color(0xFF00E676),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Outfit',
                ),
              ),
              Icon(
                Icons.flash_on_rounded,
                color: Color(0xFF00E676),
                size: 8,
              ),
            ],
          ),
        );
        break;
      case 'urban company':
        vectorFallback = const Center(
          child: Text(
            'UC',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              fontFamily: 'Outfit',
            ),
          ),
        );
        break;
      case 'dhl':
        vectorFallback = const Center(
          child: Text(
            'DHL',
            style: TextStyle(
              color: Color(0xFFD40511),
              fontWeight: FontWeight.w900,
              fontSize: 10,
              fontStyle: FontStyle.italic,
              letterSpacing: -0.5,
            ),
          ),
        );
        break;
      case 'bluedart':
        vectorFallback = const Center(
          child: Text(
            'BD',
            style: TextStyle(
              color: Color(0xFFFFCC00),
              fontWeight: FontWeight.w900,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
        break;
      case 'fedex':
        vectorFallback = const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Fed',
                style: TextStyle(
                  color: Color(0xFF4D148C),
                  fontWeight: FontWeight.bold,
                  fontSize: 8,
                ),
              ),
              Text(
                'Ex',
                style: TextStyle(
                  color: Color(0xFFFF6200),
                  fontWeight: FontWeight.bold,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        );
        break;
      case 'blinkit':
      case 'blink it':
        vectorFallback = const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'blink',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 7,
                  fontFamily: 'Outfit',
                ),
              ),
              Text(
                'it',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 7,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        );
        break;
      case 'ola':
      case 'ola cabs':
        vectorFallback = const Center(
          child: Text(
            'ola',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              fontFamily: 'Outfit',
              letterSpacing: -0.5,
            ),
          ),
        );
        break;
      case 'rapido':
        vectorFallback = const Center(
          child: Text(
            'rapido',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 9,
              fontFamily: 'Outfit',
              letterSpacing: -0.5,
            ),
          ),
        );
        break;
      default:
        vectorFallback = CircleAvatar(
          backgroundColor: defaultColor.withAlpha(20),
          radius: 18,
          child: Icon(defaultIcon, color: defaultColor, size: 18),
        );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          'https://logos.hunter.io/${brand.domain}',
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: brand.primaryColor,
              child: vectorFallback,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: brand.primaryColor.withAlpha(50),
              child: const Center(
                child: SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _purpose = 'Guest';
  String _deliveryProvider = 'Swiggy';
  String _taxiProvider = 'Uber';
  String _maintenanceProvider = 'Urban Company';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showDeliveryProviderSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final brands = [
      {'name': 'Swiggy', 'color': const Color(0xFFFC8019), 'icon': Icons.fastfood_rounded},
      {'name': 'Zomato', 'color': const Color(0xFFCB202D), 'icon': Icons.restaurant_rounded},
      {'name': 'Blinkit', 'color': const Color(0xFFFFD54F), 'icon': Icons.shopping_basket_rounded},
      {'name': 'Amazon', 'color': const Color(0xFFFF9900), 'icon': Icons.local_mall_rounded},
      {'name': 'Flipkart', 'color': const Color(0xFF2874F0), 'icon': Icons.shopping_bag_rounded},
      {'name': 'Other', 'color': AppColors.primary, 'icon': Icons.more_horiz_rounded},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool showCustomInput = false;
        final localController = TextEditingController(
          text: _deliveryProvider != 'Swiggy' &&
                  _deliveryProvider != 'Zomato' &&
                  _deliveryProvider != 'Blinkit' &&
                  _deliveryProvider != 'Amazon' &&
                  _deliveryProvider != 'Flipkart'
              ? _deliveryProvider
              : '',
        );
        final localFormKey = GlobalKey<FormState>();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: localFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        showCustomInput ? 'Enter Custom Provider' : 'Select Delivery Provider',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      if (!showCustomInput)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: brands.length,
                          itemBuilder: (context, index) {
                            final brand = brands[index];
                            final brandColor = brand['color'] as Color;
                            final brandIcon = brand['icon'] as IconData;
                            final brandName = brand['name'] as String;

                            return InkWell(
                              onTap: () {
                                if (brandName == 'Other') {
                                  setDialogState(() {
                                    showCustomInput = true;
                                  });
                                } else {
                                  setState(() {
                                    _deliveryProvider = brandName;
                                  });
                                  Navigator.of(context).pop();
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkBg : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark ? AppColors.glassBorder : Colors.grey[300]!,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildBrandLogoWidget(brandName, brandIcon, brandColor),
                                    const SizedBox(height: 6),
                                    Text(
                                      brandName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      else ...[
                        TextFormField(
                          controller: localController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: 'Company / Service Name',
                            prefixIcon: Icon(Icons.business_rounded),
                            hintText: 'e.g. Dunzo, DHL, FedEx',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the company name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setDialogState(() {
                                  showCustomInput = false;
                                });
                              },
                              child: const Text('Back'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (localFormKey.currentState!.validate()) {
                                  setState(() {
                                    _deliveryProvider = localController.text.trim();
                                  });
                                  Navigator.of(context).pop();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                minimumSize: const Size(100, 44),
                              ),
                              child: const Text('Confirm'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showTaxiProviderSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final brands = [
      {'name': 'Uber', 'color': const Color(0xFF000000), 'icon': Icons.local_taxi_rounded},
      {'name': 'Ola', 'color': const Color(0xFF80C000), 'icon': Icons.local_taxi_rounded},
      {'name': 'Rapido', 'color': const Color(0xFFFFD600), 'icon': Icons.motorcycle_rounded},
      {'name': 'Yatri', 'color': const Color(0xFF009688), 'icon': Icons.directions_car_rounded},
      {'name': 'Other', 'color': AppColors.primary, 'icon': Icons.more_horiz_rounded},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String mode = 'selectBrand'; // 'selectBrand', 'enterCustomBrand', 'enterCabDetails'
        String tempTaxiBrand = '';
        
        final customBrandController = TextEditingController();
        final cabDigitsController = TextEditingController();
        final localFormKey = GlobalKey<FormState>();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: localFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        mode == 'selectBrand'
                            ? 'Select Taxi Provider'
                            : (mode == 'enterCustomBrand' ? 'Enter Custom Taxi' : 'Enter Cab Details'),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      
                      // 1. SELECT BRAND MODE
                      if (mode == 'selectBrand')
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: brands.length,
                          itemBuilder: (context, index) {
                            final brand = brands[index];
                            final brandColor = brand['color'] as Color;
                            final brandIcon = brand['icon'] as IconData;
                            final brandName = brand['name'] as String;

                            return InkWell(
                              onTap: () {
                                if (brandName == 'Other') {
                                  setDialogState(() {
                                    mode = 'enterCustomBrand';
                                  });
                                } else {
                                  setDialogState(() {
                                    tempTaxiBrand = brandName;
                                    mode = 'enterCabDetails';
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkBg : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark ? AppColors.glassBorder : Colors.grey[300]!,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildBrandLogoWidget(brandName, brandIcon, brandColor),
                                    const SizedBox(height: 6),
                                    Text(
                                      brandName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        
                      // 2. ENTER CUSTOM BRAND MODE
                      if (mode == 'enterCustomBrand') ...[
                        TextFormField(
                          controller: customBrandController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: 'Taxi / Service Name',
                            prefixIcon: Icon(Icons.local_taxi_rounded),
                            hintText: 'e.g. InDrive, Meru, Local Cab',
                          ),
                          validator: (value) {
                            if (mode == 'enterCustomBrand' && (value == null || value.trim().isEmpty)) {
                              return 'Please enter the taxi provider name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setDialogState(() {
                                  mode = 'selectBrand';
                                });
                              },
                              child: const Text('Back'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (localFormKey.currentState!.validate()) {
                                  setDialogState(() {
                                    tempTaxiBrand = customBrandController.text.trim();
                                    mode = 'enterCabDetails';
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                minimumSize: const Size(100, 44),
                              ),
                              child: const Text('Next'),
                            ),
                          ],
                        ),
                      ],

                      // 3. ENTER CAB DETAILS MODE (LAST 4 DIGITS)
                      if (mode == 'enterCabDetails') ...[
                        TextFormField(
                          controller: cabDigitsController,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          decoration: const InputDecoration(
                            labelText: 'Last 4 Digits of Cab Number',
                            prefixIcon: Icon(Icons.numbers_rounded),
                            hintText: 'e.g. 5821',
                            counterText: '', // Hide default counter
                          ),
                          validator: (value) {
                            if (mode == 'enterCabDetails') {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter 4 digits';
                              }
                              if (value.trim().length != 4 || int.tryParse(value) == null) {
                                return 'Must be exactly 4 digits';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setDialogState(() {
                                  // Go back to custom input if they had chosen Other, else go to grid selector
                                  if (customBrandController.text.trim().isNotEmpty) {
                                    mode = 'enterCustomBrand';
                                  } else {
                                    mode = 'selectBrand';
                                  }
                                });
                              },
                              child: const Text('Back'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (localFormKey.currentState!.validate()) {
                                  setState(() {
                                    _taxiProvider = '$tempTaxiBrand (Cab: ${cabDigitsController.text.trim()})';
                                  });
                                  Navigator.of(context).pop();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                minimumSize: const Size(100, 44),
                              ),
                              child: const Text('Confirm'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMaintenanceProviderSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final brands = [
      {'name': 'Urban Company', 'color': const Color(0xFF101010), 'icon': Icons.cleaning_services_rounded},
      {'name': 'Other', 'color': AppColors.primary, 'icon': Icons.more_horiz_rounded},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool showCustomInput = false;
        final localController = TextEditingController(
          text: _maintenanceProvider != 'Urban Company' ? _maintenanceProvider : '',
        );
        final localFormKey = GlobalKey<FormState>();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: localFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        showCustomInput ? 'Enter Custom Brand' : 'Select Maintenance Provider',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      if (!showCustomInput)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: brands.length,
                          itemBuilder: (context, index) {
                            final brand = brands[index];
                            final brandColor = brand['color'] as Color;
                            final brandIcon = brand['icon'] as IconData;
                            final brandName = brand['name'] as String;

                            return InkWell(
                              onTap: () {
                                if (brandName == 'Other') {
                                  setDialogState(() {
                                    showCustomInput = true;
                                  });
                                } else {
                                  setState(() {
                                    _maintenanceProvider = brandName;
                                  });
                                  Navigator.of(context).pop();
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkBg : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark ? AppColors.glassBorder : Colors.grey[300]!,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildBrandLogoWidget(brandName, brandIcon, brandColor),
                                    const SizedBox(height: 6),
                                    Text(
                                      brandName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      else ...[
                        TextFormField(
                          controller: localController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: 'Company / Brand Name',
                            prefixIcon: Icon(Icons.engineering_rounded),
                            hintText: 'e.g. Local Electrician, Plumber',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the company name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setDialogState(() {
                                  showCustomInput = false;
                                });
                              },
                              child: const Text('Back'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (localFormKey.currentState!.validate()) {
                                  setState(() {
                                    _maintenanceProvider = localController.text.trim();
                                  });
                                  Navigator.of(context).pop();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                minimumSize: const Size(100, 44),
                              ),
                              child: const Text('Confirm'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<ResidentProvider>(context, listen: false);
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);

      final success = await provider.createInvite(
        userId: widget.userId,
        visitorName: _nameController.text.trim(),
        purpose: _purpose == 'Delivery'
            ? 'Delivery: $_deliveryProvider'
            : (_purpose == 'Taxi'
                ? 'Taxi: $_taxiProvider'
                : (_purpose == 'Maintenance' ? 'Maintenance: $_maintenanceProvider' : _purpose)),
        inviteDate: _selectedDate,
        flatNumber: widget.flatNumber,
        hostName: widget.hostName,
      );

      if (success && mounted) {
        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Visitor invitation code generated successfully!'),
            backgroundColor: AppColors.secondary,
          ),
        );
      } else if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to generate invite'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResidentProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 8,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Invite Visitor',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    )
                  ],
                ),
                const SizedBox(height: 20),

                // Visitor Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Visitor Name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                    hintText: 'Enter name (e.g. John Doe)',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter visitor name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Purpose Dropdown
                DropdownButtonFormField<String>(
                  value: _purpose,
                  decoration: const InputDecoration(
                    labelText: 'Purpose of Visit',
                    prefixIcon: Icon(Icons.info_outline_rounded),
                  ),
                  items: ['Guest', 'Delivery', 'Maintenance', 'Taxi', 'Other']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _purpose = val;
                      });
                      if (val == 'Delivery') {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _showDeliveryProviderSelector(context);
                        });
                      } else if (val == 'Taxi') {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _showTaxiProviderSelector(context);
                        });
                      } else if (val == 'Maintenance') {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _showMaintenanceProviderSelector(context);
                        });
                      }
                    }
                  },
                ),
                if (_purpose == 'Delivery') ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBg : AppColors.lightSurfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.glassBorder : AppColors.lightTextMuted.withAlpha(30),
                      ),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.secondary,
                          radius: 16,
                          child: Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Provider',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _deliveryProvider,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _showDeliveryProviderSelector(context),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: Size.zero,
                          ),
                          child: const Text('Change', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_purpose == 'Taxi') ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBg : AppColors.lightSurfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.glassBorder : AppColors.lightTextMuted.withAlpha(30),
                      ),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.secondary,
                          radius: 16,
                          child: Icon(Icons.local_taxi_rounded, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Taxi Provider',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _taxiProvider,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _showTaxiProviderSelector(context),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: Size.zero,
                          ),
                          child: const Text('Change', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_purpose == 'Maintenance') ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBg : AppColors.lightSurfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.glassBorder : AppColors.lightTextMuted.withAlpha(30),
                      ),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.secondary,
                          radius: 16,
                          child: Icon(Icons.engineering_rounded, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Maintenance Provider',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _maintenanceProvider,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _showMaintenanceProviderSelector(context),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: Size.zero,
                          ),
                          child: const Text('Change', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Date Picker field
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBg : AppColors.lightSurfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.glassBorder : AppColors.lightTextMuted.withAlpha(30),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date of Visit',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Save button
                provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Generate Invite Code'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogBrandInfo {
  final String domain;
  final Color primaryColor;
  final Color fallbackTextColor;
  
  _DialogBrandInfo({
    required this.domain,
    required this.primaryColor,
    required this.fallbackTextColor,
  });
}
