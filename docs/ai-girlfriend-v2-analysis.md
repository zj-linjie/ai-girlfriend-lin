# ai-girlfriend-v2 + RunningHub 数字人方案分析(2026-09-20)

> 两个子代理并行深挖的汇总:仓库源码级分析 + RunningHub 工作流调研。回答三个问题:能否在 M4/16GB Mac 上跑、是否实时、能否去掉 DSH。

## 一、ai-girlfriend-v2 项目本体

[Work-Fisher/ai-girlfriend-v2](https://github.com/Work-Fisher/ai-girlfriend-v2):**2026-09-19 刚发布**(9 个 commit、16 stars、无 license、深度绑定 Windows 整合包)。

### 架构(五个本地服务,全部绑 127.0.0.1)

| 端口 | 服务 | 实现 | Mac 可行性 |
| --- | --- | --- | --- |
| 7860 | 浏览器 UI | FastAPI + 静态页 | ✅ 无障碍 |
| 8766 | 实时语音管线 | HF speech-to-speech 0.2.11 fork(VAD→STT→LLM→TTS) | ✅ 上游原生支持 MPS/MLX |
| 8790 | DSH bridge | DeepSeek Harness 的 OpenAI 兼容封装 | ❌ 见下,可拆 |
| 8791 | OmniVoice TTS | 参考音频声音克隆,非流式 | ⚠️ 有 CPU 回退,慢 |
| 8383 | 数字人口型 | Duix/HeyGem,跑 WSL2 或 CUDA Docker | ❌ 硬障碍 |

- LLM 不在本地:GLM/Kimi/DeepSeek/任意 OpenAI 兼容 API(设置面板选)
- STT:Whisper large-v3-turbo,配置**钉死 cuda**;上游有 `mlx-audio-whisper` 后端可换
- 记忆:SQLite + E5-small 本地 embedding(纯 Python/CPU,**与 DSH 无关,可独立保留**)

### DSH 是什么、能不能拆

**DSH = DeepSeek Harness**:一个类似 coding-agent 的有状态会话运行时(闭源 Windows x64 二进制,来自整合包 `deepseek-harness-sdk-runtime-win-x64.exe`),被当作"带跨重启记忆的大脑"。仓库内 33 个文件、151 处引用。

**可以拆**:UI 的 LLM 代理(`app/ui/server.py:1130`)已有完整的"取 base_url/key/model → 直连厂商 → 流式回传"逻辑,把 `DSH_BRIDGE_URL` 改直连即可绕过;代价是失去 DSH 的会话级记忆,但 `long_term_memory.py`(SQLite 事实库 + 语义检索)是独立的,可保留。

### 实时性判定(用户怀疑属实)

- **数字人开启 = 批量渲染 MP4**:每轮回复完整生成后整段提交 HeyGem,轮询等成片(引擎冷启动 1-3 分钟,渲染数秒~数十秒),完事播放视频。**不是实时数字人。**
- **纯语音模式 = 准实时但非流式**:等 LLM 完整生成 → 按句切分逐段 TTS,首字延迟接近流式体验。

### 在 M4/16GB 上跑起来的判定

- **完整体验:不可能**。数字人靠 WSL2 + NVIDIA CUDA 双重死锁;DSH 无 Mac 二进制;PyTorch 是 CUDA 13.0 build;启动脚本全 PowerShell;**仓库无 requirements.txt**(依赖封在 Windows venv 里,官方承认无可复现构建脚本)。
- **纯语音版(≈80% 功能):可行,但属于移植项目而非安装**——重建 Python 环境(按 import 反推依赖)、模型走 hf-mirror(约 5GB)、配置改 `mps`/`mlx`、手工替代 4 个 PowerShell 脚本、写无 DSH 的 bridge。预计数天工作量。
- 16GB 内存:纯语音模式可容纳(MLX whisper ~1.5GB + E5 0.5GB + OmniVoice ~3GB),但 OmniVoice CPU 合成会是延迟瓶颈。

## 二、RunningHub「infinitetalk单人」工作流

帖子是 ComfyUI 工作流「infinitetalk单人」,技术底座为 **InfiniteTalk/MultiTalk**(美团 MeiGen-AI,Wan2.1 14B 视频扩散):输入一张图 + 一段音频 → 输出口型同步 MP4。

- **定性:纯离线批量生成,与"对话式伴侣"不匹配**。4090 级 GPU 上 10 秒视频标准参数 10-20 分钟、4 步蒸馏 LoRA 优化版 2-5 分钟,再加排队;**每轮对话延迟 3-10 分钟,比实时慢两个数量级**。
- 计费:按 GPU 秒(¥2.5-6/小时档),单次约 ¥0.2-0.7;新用户有免费 RH 币。
- API:有完整 OpenAPI(上传素材 → 提交任务填 nodeInfoList → 轮询 → 取 MP4 直链,支持 webhook,n8n 有现成节点)。文档:[runninghub API](https://www.runninghub.cn/runninghub-api-doc-cn/doc-8287334)
- 正确定位:**离线内容生产器**(如"每日一条问候视频",10 条/天 ≈ ¥100-150/月),不是对话视频通道。若真要"对话后快速出片",应选 MuseTalk/LivePortrait 类 lip-sync 工作流(RTF≈1,单轮 30-60 秒),而非 InfiniteTalk。
- M4 本地跑 InfiniteTalk:16GB 统一内存跑 14B 扩散模型不现实,排除。

## 三、综合建议

1. **不要整体采用 ai-girlfriend-v2**:发布仅一天、无 license、Windows 整合包形态,Mac 上是移植项目;其价值在于"抄作业"——记忆模块设计(SQLite+E5)、OmniVoice 声音克隆、五服务架构可借鉴。
2. **对话式语音陪伴**:仍以 Open-LLM-VTuber 为底座(开箱即用,配置即生效)。
3. **如果想要"数字人视频"这个体验**:作为异步功能接 RunningHub API——LLM+TTS 出一段问候音频 → lip-sync 类工作流出片 → 推送播放;不进入对话回路。
4. DSH 不需要:直连任意 LLM API(现有 Agnes 即可)+ 借鉴其记忆模块即可复刻"有记忆的女友"核心。
