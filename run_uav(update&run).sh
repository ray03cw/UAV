cat << 'EOF' > ~/Software/UAV-Downloader/run_uav.sh
#!/bin/bash

# エラーが起きても進められるようにするよ
set -e

UAV_DIR="$HOME/Software/UAV-Downloader"

if [ ! -d "$UAV_DIR" ]; then
    echo "❌ 指定されたディレクトリが見つからないよ: $UAV_DIR"
    exit 1
fi

cd "$UAV_DIR"

echo "🔄 UAV-Downloader のアップデートを確認しているよ..."

# 1. リモートから最新情報を安全に取得するよ
git fetch origin > /dev/null 2>&1 || true

# 2. 現在のブランチのデフォルトリモートブランチ（例: origin/main や origin/master）を自動検出するよ
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
REMOTE_BRANCH="origin/$CURRENT_BRANCH"

# もし現在のブランチに対応するリモートがなければ、一般的な main か master を探すよ
if ! git show-ref --verify --quiet refs/remotes/$REMOTE_BRANCH; then
    if git show-ref --verify --quiet refs/remotes/origin/main; then
        REMOTE_BRANCH="origin/main"
    elif git show-ref --verify --quiet refs/remotes/origin/master; then
        REMOTE_BRANCH="origin/master"
    else
        REMOTE_BRANCH=""
    fi
fi

# 3. リモートブランチが見つかった場合のみ比較してアップデートするよ
if [ -n "$REMOTE_BRANCH" ]; then
    LOCAL=$(git rev-parse HEAD 2>/dev/null || echo "")
    REMOTE=$(git rev-parse $REMOTE_BRANCH 2>/dev/null || echo "")

    if [ "$LOCAL" != "$REMOTE" ] && [ -n "$REMOTE" ]; then
        echo "✨ 新しいバージョンが見つかったよ！自動でアップデートするね〜っ！"
        git pull origin "$CURRENT_BRANCH"
        
        if [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
            if [ -d "venv" ]; then
                source venv/bin/activate
                pip install -e . > /dev/null 2>&1 || true
                deactivate
            else
                pip install -e . > /dev/null 2>&1 || true
            fi
        fi
        echo "🎉 アップデートが完了したよ！"
    else
        echo "👍 すでに最新バージョンだよ！そのまま起動するねっ。"
    fi
else
    echo "⚠️ リモートブランチが見つからないため、そのまま起動するね。"
fi

echo "🚀 UAV Browser を起動するよ〜っ！"

# 4. 仮想環境がある場合は有効化して起動、なければそのまま起動
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
    uav-browser &
    deactivate
else
    uav-browser &
fi
EOF

# 自動的に実行権限を付与するよ
chmod +x ~/Software/UAV-Downloader/run_uav.sh
