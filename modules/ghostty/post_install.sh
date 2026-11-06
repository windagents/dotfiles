#!/bin/bash
# ghostty post_install: Ubuntu/Debian 旧版本官方仓库没有 ghostty, 用社区 .deb 补装
set -euo pipefail

case "${DISTRO_ID:-}" in
    arch|darwin) exit 0 ;;   # 已由 packages.arch / packages.darwin 安装
esac

if command -v ghostty >/dev/null 2>&1; then
    ok "ghostty 已安装, 跳过"
    exit 0
fi

if [ -n "${DRY_RUN:-}" ]; then
    warn "(dry-run) 将安装 ghostty (官方 apt 或社区 .deb)"
    exit 0
fi

# Ubuntu 26.04+ / Debian trixie+ 官方 apt 仓库已收录
if apt-cache policy ghostty 2>/dev/null | grep -qE '^[[:space:]]+Candidate: [0-9]'; then
    log "通过 apt 安装 ghostty..."
    if sudo apt-get install -y ghostty; then
        ok "ghostty 安装完成"
    else
        warn "apt 安装 ghostty 失败, 可稍后手动安装"
    fi
    exit 0
fi

# 旧版 Ubuntu/Debian 使用社区 .deb (支持 Ubuntu 24.04+ / Debian trixie+)
command -v curl >/dev/null 2>&1 || { warn "安装 ghostty 需要 curl, 跳过"; exit 0; }
log "官方仓库无 ghostty, 尝试社区 .deb (ghostty-ubuntu)..."
tmpdir="$(mktemp -d)"
if ( cd "$tmpdir" && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)" ); then
    ok "ghostty 安装完成"
else
    warn "ghostty 自动安装失败 (Ubuntu 22.04 等旧版本无可用构建), 请手动安装: https://ghostty.org/docs/install/binary"
fi
rm -rf "$tmpdir"
