import 'package:totp_auth/core/totp.dart';

/// TOTP 账户模型
class TotpAccount {
  /// 唯一标识
  final String id;

  /// 发行方（如 Google, GitHub 等）
  final String issuer;

  /// 账户名（如邮箱、用户名）
  final String accountName;

  /// Base32 编码的密钥
  final String secret;

  /// 哈希算法
  final TotpHashAlgorithm algorithm;

  /// 验证码位数（6 或 8）
  final int digits;

  /// 时间步长（秒）
  final int period;

  /// 排序权重
  final int sortOrder;

  /// 创建时间
  final DateTime createdAt;

  TotpAccount({
    required this.id,
    required this.issuer,
    required this.accountName,
    required this.secret,
    this.algorithm = TotpHashAlgorithm.sha1,
    this.digits = 6,
    this.period = 30,
    this.sortOrder = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 显示名称
  String get displayName {
    if (issuer.isNotEmpty) {
      return '$issuer ($accountName)';
    }
    return accountName;
  }

  /// 简短显示名称
  String get shortName => issuer.isNotEmpty ? issuer : accountName;

  /// 生成 otpauth:// URI
  String toOtpAuthUri() {
    final label = issuer.isNotEmpty
        ? '${Uri.encodeComponent(issuer)}:${Uri.encodeComponent(accountName)}'
        : Uri.encodeComponent(accountName);

    final params = <String, String>{
      'secret': secret,
      if (issuer.isNotEmpty) 'issuer': issuer,
      if (algorithm != TotpHashAlgorithm.sha1) 'algorithm': algorithm.name,
      if (digits != 6) 'digits': digits.toString(),
      if (period != 30) 'period': period.toString(),
    };

    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return 'otpauth://totp/$label?$query';
  }

  /// 从 otpauth:// URI 解析
  static TotpAccount fromOtpAuthUri(String uri, {String? id}) {
    final parsed = Uri.parse(uri);

    if (parsed.scheme != 'otpauth' || parsed.host != 'totp') {
      throw FormatException('Invalid otpauth URI: $uri');
    }

    // 解析 label: "issuer:accountName" 或 "accountName"
    var issuer = '';
    var accountName = '';
    final path = parsed.path.substring(1); // 移除前导 /
    if (path.contains(':')) {
      final parts = path.split(':');
      issuer = Uri.decodeComponent(parts[0]);
      accountName = Uri.decodeComponent(parts.sublist(1).join(':'));
    } else {
      accountName = Uri.decodeComponent(path);
    }

    final params = parsed.queryParameters;
    final secret = params['secret'] ?? '';
    if (secret.isEmpty) {
      throw FormatException('Missing secret in otpauth URI');
    }

    // issuer 也可以在 query 参数中指定
    if (issuer.isEmpty && params.containsKey('issuer')) {
      issuer = params['issuer']!;
    }

    return TotpAccount(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      issuer: issuer,
      accountName: accountName,
      secret: secret,
      algorithm: TotpHashAlgorithm.fromString(params['algorithm']),
      digits: int.tryParse(params['digits'] ?? '6') ?? 6,
      period: int.tryParse(params['period'] ?? '30') ?? 30,
    );
  }

  /// 从 JSON 创建
  factory TotpAccount.fromJson(Map<String, dynamic> json) {
    return TotpAccount(
      id: json['id'] as String,
      issuer: json['issuer'] as String? ?? '',
      accountName: json['accountName'] as String,
      secret: json['secret'] as String,
      algorithm: TotpHashAlgorithm.fromString(json['algorithm'] as String?),
      digits: json['digits'] as int? ?? 6,
      period: json['period'] as int? ?? 30,
      sortOrder: json['sortOrder'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : null,
    );
  }

  /// 转为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'issuer': issuer,
      'accountName': accountName,
      'secret': secret,
      'algorithm': algorithm.name,
      'digits': digits,
      'period': period,
      'sortOrder': sortOrder,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// 复制并修改部分字段
  TotpAccount copyWith({
    String? id,
    String? issuer,
    String? accountName,
    String? secret,
    TotpHashAlgorithm? algorithm,
    int? digits,
    int? period,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return TotpAccount(
      id: id ?? this.id,
      issuer: issuer ?? this.issuer,
      accountName: accountName ?? this.accountName,
      secret: secret ?? this.secret,
      algorithm: algorithm ?? this.algorithm,
      digits: digits ?? this.digits,
      period: period ?? this.period,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TotpAccount && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
