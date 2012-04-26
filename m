Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id AEB026B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 19:25:48 -0400 (EDT)
Date: Thu, 26 Apr 2012 16:25:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH next 00/12] mm: replace struct mem_cgroup_zone with
 struct lruvec
Message-Id: <20120426162546.90991b7c.akpm@linux-foundation.org>
In-Reply-To: <20120426074632.18961.17803.stgit@zurg>
References: <20120426074632.18961.17803.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 26 Apr 2012 11:53:44 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> This patchset depends on Johannes Weiner's patch
> "mm: memcg: count pte references from every member of the reclaimed hierarchy".
> 
> bloat-o-meter delta for patches 2..12
> 
> add/remove: 6/6 grow/shrink: 6/14 up/down: 4414/-4625 (-211)

That's the sole effect and intent of the patchset?  To save 211 bytes?

> ...
>
>  include/linux/memcontrol.h |   16 +--
>  include/linux/mmzone.h     |   14 ++
>  mm/memcontrol.c            |   33 +++--
>  mm/mmzone.c                |   14 ++
>  mm/page_alloc.c            |    8 -
>  mm/vmscan.c                |  277 ++++++++++++++++++++------------------------
>  6 files changed, 177 insertions(+), 185 deletions(-)

If so, I'm not sure that it is worth the risk and effort?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
