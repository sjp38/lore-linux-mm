Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 43B076B0071
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 10:47:19 -0400 (EDT)
Date: Thu, 5 Jul 2012 09:47:14 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 2/4] mm: make consistent use of PG_slab flag
In-Reply-To: <1341287837-7904-2-git-send-email-jiang.liu@huawei.com>
Message-ID: <alpine.DEB.2.00.1207050945310.4984@router.home>
References: <1341287837-7904-1-git-send-email-jiang.liu@huawei.com> <1341287837-7904-2-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

On Tue, 3 Jul 2012, Jiang Liu wrote:

> PG_slabobject:	mark whether a (compound) page hosts SLUB/SLOB objects.

Any subsystem may allocate a compound page to store metadata.

The compound pages used by SLOB and SLUB are not managed in any way but
the calls to kfree and kmalloc are converted to calls to the page
allocator. There is no "management" by the slab allocators for these
cases and its inaccurate to say that these are SLUB/SLOB objects since the
allocators never deal with these objects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
