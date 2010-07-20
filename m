Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7FD406B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 15:30:02 -0400 (EDT)
Subject: Re: [PATCH 1/3] mm: add context argument to shrinker callback
From: Alex Elder <aelder@sgi.com>
Reply-To: aelder@sgi.com
In-Reply-To: <1279194418-16119-2-git-send-email-david@fromorbit.com>
References: <1279194418-16119-1-git-send-email-david@fromorbit.com>
	 <1279194418-16119-2-git-send-email-david@fromorbit.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 20 Jul 2010 14:30:04 -0500
Message-ID: <1279654204.1859.232.camel@doink>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: xfs@oss.sgi.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-07-15 at 21:46 +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> The current shrinker implementation requires the registered callback
> to have global state to work from. This makes it difficult to shrink
> caches that are not global (e.g. per-filesystem caches). Pass the shrinker
> structure to the callback so that users can embed the shrinker structure
> in the context the shrinker needs to operate on and get back to it in the
> callback via container_of().

> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  arch/x86/kvm/mmu.c              |    2 +-
>  drivers/gpu/drm/i915/i915_gem.c |    2 +-
>  fs/dcache.c                     |    2 +-
>  fs/gfs2/glock.c                 |    2 +-
>  fs/gfs2/quota.c                 |    2 +-
>  fs/gfs2/quota.h                 |    2 +-
>  fs/inode.c                      |    2 +-
>  fs/mbcache.c                    |    5 +++--
>  fs/nfs/dir.c                    |    2 +-
>  fs/nfs/internal.h               |    3 ++-
>  fs/quota/dquot.c                |    2 +-
>  fs/ubifs/shrinker.c             |    2 +-
>  fs/ubifs/ubifs.h                |    2 +-
>  fs/xfs/linux-2.6/xfs_buf.c      |    5 +++--
>  fs/xfs/linux-2.6/xfs_sync.c     |    1 +
>  fs/xfs/quota/xfs_qm.c           |    7 +++++--
>  include/linux/mm.h              |    2 +-
>  mm/vmscan.c                     |    8 +++++---
>  18 files changed, 31 insertions(+), 22 deletions(-)

You seem to have missed two registered shrinkers:
- ttm_pool_mm_shrink() in "drivers/gpu/drm/ttm/ttm_page_alloc.c"
- rpcauth_cache_shrinker() in "net/sunrpc/auth.c"

Other that that, this looks good to me.

					-Alex





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
