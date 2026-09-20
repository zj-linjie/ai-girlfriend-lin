# ai-girlfriend-lin

在 Apple Silicon Mac(M4 / 16 GB)上落地一个可日常使用的 macOS AI Companion。

核心原则:**先证明"现成产品是否已经够用",再决定开发。**

## 路线图与门禁

| 阶段 | 内容 | 启动条件 | 状态 |
| --- | --- | --- | --- |
| **A · 现成部署与真实体验基线** | 部署 AIRI 官方桌面版,跑通 LLM + STT + TTS 最小语音链路,完成 20 分钟连续真实对话实测 | 无(当前阶段) | 🚧 进行中 |
| **B · MuseTalk-Mac 真人 Avatar 基准** | 独立基准测试 /warmup、/lipsync_stream、完整 MP4 生成耗时、峰值内存与 swap;不承诺实时 | 仅当 A 成立、真人形象仍是需求、有授权人像视频、本机资源允许时另立 issue | ⛔ 未启动 |
| **C · AIRI × 真人 Avatar 最小闭环** | 旧轮次迟到结果丢弃、打断后渲染不串台、避免语音与带声视频重复回答 | 仅 B 通过后考虑 | ⛔ 未启动 |
| **D · OpenAI Realtime / GPT Live** | WebRTC 双向语音、短期凭据、打断、断线恢复与成本验证 | 仅基线稳定且有独立 OpenAI API 预算时另立 issue | ⛔ 未启动 |

## 当前状态:阶段 A

- 目标机器:Mac mini(M4,16 GB),macOS 27.0
- AIRI:`brew install --cask airi`(稳定版),MIT 许可,Apple Silicon 官方支持
- 安装与配置说明:[docs/phase-a-install.md](docs/phase-a-install.md)
- 脱敏配置样例:[config/airi-providers.example.md](config/airi-providers.example.md)
- 20 分钟实测方案:[docs/phase-a-test-plan.md](docs/phase-a-test-plan.md)
- 实测记录:[docs/phase-a-test-record.md](docs/phase-a-test-record.md)
- 阶段结论(GO / KEEP / NO-GO):[docs/phase-a-conclusion.md](docs/phase-a-conclusion.md)

## 仓库结构

```
ai-girlfriend-lin/
├── README.md                        # 本文件:路线图与阶段状态
├── docs/
│   ├── phase-a-install.md           # 可复现的安装/配置说明(版本、来源、授权)
│   ├── phase-a-test-plan.md         # 20 分钟实测方案(场景、口径、监控方法)
│   ├── phase-a-test-record.md       # 实测记录表(待填写)
│   └── phase-a-conclusion.md        # 阶段 A go/no-go 结论(待填写)
├── config/
│   └── airi-providers.example.md    # 脱敏配置样例(不含真实 Key)
└── scripts/
    └── monitor-airi.sh              # 实测期间的 CPU/内存/swap 采样脚本
```

## 阶段 A 边界(非目标)

不移植 Windows/NVIDIA 项目、不重写 AIRI、不提前开发通用 Avatar 框架、不集成 MuseTalk-Mac、不接入 GPT Live/Realtime、不做跨会话记忆与复杂 Persona、不做自动控制电脑、不在查看源码前指定 AIRI 内部扩展点。

为追求"全本地"而提前引入 Whisper、OmniVoice、MuseTalk 等系统同样不在本阶段范围内——本阶段只验证现成云端链路是否够用。

## 安全约定

- API Key 只存放在 AIRI 本地设置中,**绝不入仓库**;`.gitignore` 已排除本地配置、录音与含隐私的日志。
- 仓库中出现的所有配置一律为脱敏样例(占位符形式)。
- 角色素材仅使用 AIRI 内置默认内容(MIT 许可);在 B 阶段门禁通过前不引入任何真人形象素材。
