Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id B80C56B0075
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 09:53:24 -0400 (EDT)
Date: Fri, 6 Jul 2012 08:53:19 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 2/4] mm: make consistent use of PG_slab flag
In-Reply-To: <4FF6A21C.9010509@huawei.com>
Message-ID: <alpine.DEB.2.00.1207060851310.26441@router.home>
References: <1341287837-7904-1-git-send-email-jiang.liu@huawei.com> <1341287837-7904-2-git-send-email-jiang.liu@huawei.com> <alpine.DEB.2.00.1207050945310.4984@router.home> <4FF5BD9D.9040101@gmail.com> <alpine.DEB.2.00.1207051236310.8670@router.home>
 <4FF6A21C.9010509@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: Jiang Liu <liuj97@gmail.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 6 Jul 2012, Jiang Liu wrote:

> 	This patch is not for hotplug, but is to fix some issues in current
> kernel, such as:
> 	1) make show_mem() on ARM and unicore32 report consistent information
> no matter which slab allocator is used.

The information is only different because allocations do not go through
the slab allocators for SLUB/SLOB.

> 	2) make /proc/kpagecount and /proc/kpageflags return accurate information.

Fix the compound handling in those and the numbers will be correct. This
is also good for other issues that may arise because the flags in the
compound head are not considered.

> 	3) Get rid of risks in mm/memory_failure.c and arch/ia64/kernel/mca_drv.c

Assuming that a slab allocation fits into a page is a dangerous
assumption. There are arches with much large page sizes. Please fix the
code.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
