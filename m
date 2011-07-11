Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id B21846B004A
	for <linux-mm@kvack.org>; Sun, 10 Jul 2011 22:01:04 -0400 (EDT)
Date: Mon, 11 Jul 2011 12:00:54 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] Remove incorrect usage of sysctl_vfs_cache_pressure
Message-ID: <20110711020054.GE23038@dastard>
References: <cover.1310331583.git.rprabhu@wnohang.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <cover.1310331583.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: raghu.prabhu13@gmail.com
Cc: akpm@linux-foundation.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, keithp@keithp.com, viro@zeniv.linux.org.uk, riel@redhat.com, swhiteho@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jack@suse.cz, Raghavendra D Prabhu <rprabhu@wnohang.net>

On Mon, Jul 11, 2011 at 02:56:23AM +0530, raghu.prabhu13@gmail.com wrote:
> From: Raghavendra D Prabhu <rprabhu@wnohang.net>
> 
> In shrinker functions, sysctl_vfs_cache_pressure variable is being used while
> trimming slab caches in general and not restricted to inode/dentry caches as
> documented for that sysctl.
> 
> Raghavendra D Prabhu (1):
>   mm/vmscan: Remove sysctl_vfs_cache_pressure from non-vfs shrinkers
> 
>  drivers/gpu/drm/i915/i915_gem.c |    2 +-

That's the only questionable use of it as it has nothing to do with
filesystems.

>  fs/gfs2/glock.c                 |    2 +-
>  fs/gfs2/quota.c                 |    2 +-
>  fs/mbcache.c                    |    2 +-
>  fs/nfs/dir.c                    |    2 +-
>  fs/quota/dquot.c                |    3 +--
>  net/sunrpc/auth.c               |    2 +-

All the others are filesystema??specific caches and as such the use of
vfs_cache_pressure to adjust the balance of reclaim is valid usage.
Especially the VFS quota cache shrinkers. ;)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
