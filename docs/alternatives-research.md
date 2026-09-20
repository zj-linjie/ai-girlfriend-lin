# 数字人替代方案调研(2026-09-20)

> 背景:阶段 A(AIRI)终止后,按本机真实约束重新选型:**Mac mini M4 / 16GB(无 NVIDIA)、国内网络、可靠性优先**。已有资源:Agnes 聚合 LLM Key、SiliconFlow Key(STT/TTS,便宜)。

## 结论:三条可行路线

### 路线 1(推荐):Open-LLM-VTuber —— 本地自部署,Live2D 语音陪伴

- 仓库:[Open-LLM-VTuber/Open-LLM-VTuber](https://github.com/Open-LLM-VTuber/Open-LLM-VTuber)(**13.8k stars,2026-05 仍在推送**,活跃维护),文档:[docs.llmvtuber.com](http://docs.llmvtuber.com/)
- **原生支持 macOS**(可完全离线运行,Apple Silicon 可用本地推理),跨平台一致
- 功能:免提语音对话、**语音打断**、Live2D 形象、**桌宠模式**(透明悬浮)、AI 主动发言、MCP、视觉感知、群聊、记忆模块、直播对接
- **与现有 Key 的兼容性(源码核实)**:
  - TTS:**内置 `siliconflow_tts`**,默认端点即 `https://api.siliconflow.cn/v1/audio/speech`,SiliconFlow Key 直接可用
  - LLM:支持一切 OpenAI 兼容 API → Agnes 直接可用
  - ASR:六种可选——本地 `sherpa_onnx` / `fun_asr` / `faster_whisper` / `whisper_cpp`(零成本),或 API:`groq_whisper`(免费,已实测本机可达 0.8s)、`openai_whisper`(兼容接口,理论上可指 SiliconFlow,待验证)
- **与 AIRI 的本质区别**:配置集中在一个 YAML(WebUI 也可改),Provider 配置即生效,不存在"卡片测试通过但会话仍走官方通道"的双层状态
- 代价:安装比"装 App"多一步(Python/uv 命令行);Live2D 模型需使用授权模型(项目附带示例模型)

### 路线 2:云数字人 API —— 如果目标是"真人形象"

| 服务 | 形象 | 实时交互 | 备注 |
| --- | --- | --- | --- |
| [讯飞虚拟人](https://www.xfyun.cn) | 2D真人/3D卡通/3D写实/超拟人 | ✅ 实时 | **限时免费开放**,个人可先验证价值 |
| 腾讯云数智人 | 2D/3D | ✅ | 企业向,可接入 IoT/App/车机 |
| 硅基智能(DPS/云 HeyGem) | 2D真人克隆 | ✅ | 需商务/按量 |
| HeyGen / D-ID(国际) | 真人克隆 | ✅ | 国内网络与支付不友好,不推荐 |

优点:形象与唇形由平台 SLA 兜底,完全绕开"16GB 无 NVIDIA"硬件墙;这是原 issue B/C 阶段(真人 Avatar)诉求的正规实现路径。缺点:按量计费、形象克隆需授权人像素材、依赖第三方云。

### 路线 3:现成 App —— 零部署兜底

字节"猫箱"、MiniMax"星野/Talkie"、Replika 等:开箱即用的语音陪伴,可靠性最高;代价是形象/人格不可控、数据在对方云端、无 Mac 桌宠形态。适合作为"先有个能说话的陪伴"的权宜选项。

## 排除项(与原因)

| 方案 | 排除原因 |
| --- | --- |
| [HeyGem(硅基智能开源)](https://blog.csdn.net) | **必须 Windows + NVIDIA**(推荐 RTX 4070+,最低 1080Ti),Mac 无缘;其云版归入路线 2 |
| MuseTalk / LiveTalking / SadTalker 本地实时唇形同步 | CUDA 依赖,16GB M4 本地无法实时 |
| AIRI(moeru-ai) | 已实测证伪并归档:Provider"配置与启用分离"导致会话管线不可控;火山/豆包语音无 OpenAI 兼容端点无法接入(详见 [phase-a-conclusion.md](phase-a-conclusion.md)) |

## 建议

先试路线 1(Open-LLM-VTuber):安装 → 配 Agnes LLM + SiliconFlow TTS + 本地 sherpa ASR(零成本起步)→ 直接沿用 [phase-a-test-plan.md](phase-a-test-plan.md) 做 20 分钟实测。若验证"语音陪伴体验"成立但想要真人形象,再以路线 2(讯飞免费额度)做 B 阶段替代验证。
