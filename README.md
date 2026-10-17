# rand

macOS에서 비밀번호를 생성하는 Swift 명령줄 도구입니다. 기본 길이는 12자리이며, 결과에는 영문 소문자, 영문 대문자, 숫자, 특수기호(`!@#$%^&*`)가 각각 최소 한 글자씩 들어갑니다.

## 프로젝트 구조

```text
rand/
├── src/rand.swift   # 소스 코드와 @main 진입점
├── bin/rand         # 빌드 결과물 (Git에서는 제외)
├── Makefile         # 빌드 및 실행 명령
├── .gitignore       # 빌드 결과물 제외
└── README.md
```

## 실행

```bash
make run
./bin/rand 16
./bin/rand --length 20
```

실행할 때마다 비밀번호 하나를 표준 출력으로 표시합니다. 출력된 비밀번호는 채팅이나 공유 문서에 붙여넣지 말고 암호 관리자에 저장하세요.
길이는 4~4096자리로 지정할 수 있으며, `-l 20`처럼 짧은 옵션도 사용할 수 있습니다.

사용법을 보려면 `./bin/rand --help` 또는 `./bin/rand -h`를 실행하세요.
잘못된 인자를 넣으면 사용법을 표준 오류에 표시하고 종료 코드 2로 끝납니다.

## 빌드

macOS의 Swift 컴파일러가 필요합니다. 프로젝트 루트에서 실행하세요.

```bash
make build
./bin/rand
```

## 어느 폴더에서나 사용하기

`~/.local/bin`이 `PATH`에 포함되어 있다면 다음과 같이 설치할 수 있습니다.

```bash
install -m 755 bin/rand ~/.local/bin/rand
rand
```

난수는 macOS Security 프레임워크의 `SecRandomCopyBytes`로 얻습니다. 문자 선택에는 편향을 피하는 거부 샘플링을 사용합니다.
