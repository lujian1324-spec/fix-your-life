# Sierro App Code Delivery

交付范围：

- Flutter 源码工程，支持 Android / iOS / Web 方向继续开发。
- Sierro 深色 UI 页面、设备页、设备详情、添加设备、通知、Insights、设置、Smart Schedule。
- OpenAPI 签名实现。
- OpenAPI 客户端骨架已按线上 Swagger 校准：账号登录（密码 MD5）、刷新 token、电站列表、添加单设备、设备列表、按证书 DTUID 查询设备、DTU 列表、设备详情、实时状态、能量流、告警列表、近端 DTU 解析接口。
- BLE 配网协议层实现：DTUID 解析、AES-128-CBC-Zero、Base64、BLE 分包/组包、配网命令。
- Figma 解出的 Sierro logo、设备图、扫码图资源，以及客户补充的真实 Sierro 产品图。
- 已录入客户补充的设备资料：Sierro 1000 / Sierro2000、容量、最大输入/输出功率、电池类型、电压、频率、硬件版本、固件版本、SN/DTU 示例。
- 已按 430×932 手机视口复查主要页面：Device 首页、设备详情、设备设置、Smart Schedule、添加设备页，修正了网页预览右侧按钮裁边和 demo 长设备名问题。
- Flutter analyze / widget test / protocol test 已通过。

当前边界：

- OpenAPI baseUrl / AppID / AppSecret / DTU 示例已收到。AppSecret 不建议写死在源码，构建时用 `--dart-define=SIERRO_APP_SECRET=...` 注入。
- 已用测试账号调用 OpenAPI：`POST /login/account` 在密码按 MD5 传入后登录成功并返回 `IOT-Token`。
- 已用 token 验证：`POST /near/dtu/checkin` 对客户 DTUID 返回成功，并返回协议号 `ED7504199`、版本 `2`。
- 已用 token 验证：客户解绑后，`GET /device/dtu/info` 返回该 DTUID 可添加，`POST /device/add/single` 已成功绑定到 `jason1324` 账号，设备 ID 为 `488330252727058433`。
- 已用 token 验证：`GET /device/details` 可查到设备详情；`GET /remote/device/state/latest` 和 `GET /remote/device/energy/flow` 当前返回 `No latest data`，说明云端暂未收到该设备的最新上报数据。
- App 现在支持通过 `--dart-define=SIERRO_TEST_ACCOUNT` / `SIERRO_TEST_PASSWORD` 启动自动云端同步：登录、拉取设备列表、读取设备详情、读取实时状态/能量流、读取告警；如果云端暂未上报实时数据，UI 会显示已绑定设备和 `Awaiting first report` 状态。
- 已核对 Swagger：Smart Schedule 对应的 `peakValley` 接口对当前测试设备返回 `The peak valley function not support`，所以当前设备无法实测削峰填谷保存。
- 真实蓝牙配网仍需要真机联调：手机系统蓝牙权限、扫描广播、连接、写入 Wi-Fi、设备入网、云端出现设备，这几步必须拿设备测。
- 本包只交付代码，不包含应用商店上架、证书、开发者账号、隐私合规提交。

常用命令：

```bash
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=SIERRO_APP_SECRET=your_app_secret
flutter build apk --debug
```
