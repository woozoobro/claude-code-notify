# claude-code-notify

Claude Code를 위한 네이티브 macOS 알림. Claude 아이콘과 함께 데스크탑 알림을 보내줍니다.

![macOS](https://img.shields.io/badge/macOS-only-black)

> 🇺🇸 [English](./README.md)

## 설치

아래 두 명령어를 터미널에서 순서대로 실행하세요:

```bash
# 1단계: 마켓플레이스 등록
claude plugin marketplace add woozoobro/claude-code-notify

# 2단계: 플러그인 설치
claude plugin install claude-code-notify@woozoobro-claude-code-notify
```

첫 실행 시 네이티브 Swift 앱을 컴파일하고 `~/.cache/claude-code-notify/`에 캐시합니다.
macOS에서 알림 권한을 요청하면 반드시 허용해 주세요.

## 업데이트

플러그인이 제대로 업데이트되지 않으면 캐시를 삭제하고 다시 설치하세요:

```bash
rm -rf ~/.claude/plugins/cache/woozoobro-claude-code-notify/
claude plugin install claude-code-notify@woozoobro-claude-code-notify
```

## 삭제

```bash
claude plugin uninstall claude-code-notify
rm -rf ~/.cache/claude-code-notify
rm -rf ~/.config/claude-code-notify
```

**필수 의존성**: `jq` (`brew install jq`로 설치)

## 기능

Claude Code에서 다음 이벤트 발생 시 데스크탑 알림을 보냅니다:

| 이벤트 | 사운드 | 시점 |
|--------|--------|------|
| **Stop** | Hero | Claude가 작업을 완료했을 때 |
| **Permission** | Submarine | 사용자 승인을 기다릴 때 |
| **Idle** | Glass | 어시스턴트가 유휴 상태일 때 |
| **Tool Failed** | Basso | 도구 호출이 실패했을 때 |

알림을 클릭하면 터미널/에디터로 포커스가 돌아옵니다.

## 사운드 테마

Claude Code 내에서 `/notify-theme` 슬래시 명령어로 알림 사운드를 변경할 수 있습니다:

**게임 테마** (커스텀 사운드 파일):

| 테마 | 분위기 |
|------|--------|
| **lol** | 소환사의 협곡 느낌 |
| **hearthstone** | 선술집의 따뜻한 카드 마법 |
| **starcraft** | 테란 커맨드 센터 알림 |

게임 테마는 `resources/<theme>/`에 저장된 커스텀 오디오 파일을 사용합니다. 원하는 사운드 파일로 교체할 수 있습니다 — `stop`, `permission`, `idle`, `tool_failed` 이름으로 아무 오디오 확장자(`.mp3`, `.wav`, `.aiff`, `.m4a` 등)의 파일을 테마 폴더에 넣으면 됩니다.

**시스템 테마** (macOS 기본 사운드):

| 테마 | Stop | Permission | Idle | Tool Failed | 분위기 |
|------|------|-----------|------|-------------|--------|
| **default** | Hero | Submarine | Glass | Basso | 깔끔하고 프로페셔널 |
| **retro** | Purr | Morse | Pop | Sosumi | 8비트 레트로 감성 |
| **minimal** | Tink | Blow | Pop | Funk | 은은하고 절제된 |
| **custom** | — | — | — | — | 각 사운드를 직접 선택 |

테마 설정은 `~/.config/claude-code-notify/config.json`에 저장됩니다.

## 작동 방식

1. Claude Code 훅 실행 → `notify.sh` 실행
2. 첫 실행 시 Swift `.app` 번들 자동 컴파일 (`~/.cache/claude-code-notify/`에 캐시)
3. 네이티브 macOS API로 Claude 아이콘과 함께 알림 전달
4. 알림 클릭 → 호출 앱으로 포커스 복귀 (VSCode, Cursor, iTerm, Terminal, ghostty, Warp, Alacritty, kitty, Windsurf)

## 문제 해결

알림이 제대로 작동하지 않는 경우:

1. 캐시된 앱 번들을 삭제하고 다음 실행 시 재빌드하세요:
   ```bash
   rm -rf ~/.cache/claude-code-notify
   ```
2. **시스템 설정 → 알림**에서 **CC**를 찾아 우클릭 후 알림 설정을 초기화하세요
