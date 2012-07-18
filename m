Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 08CD56B005A
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 11:30:09 -0400 (EDT)
Date: Wed, 18 Jul 2012 10:30:05 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: RE: [PATCH] mm/slub: fix a BUG_ON() when offlining a memory node
 and CONFIG_SLUB_DEBUG is on
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F1936AB66@ORSMSX104.amr.corp.intel.com>
Message-ID: <alpine.DEB.2.00.1207181029480.22907@router.home>
References: <1342543816-10853-1-git-send-email-jiang.liu@huawei.com> <alpine.DEB.2.00.1207171237320.15177@router.home> <3908561D78D1C84285E8C5FCA982C28F1936AB66@ORSMSX104.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Jiang Liu <liuj97@gmail.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Jianguo Wu <wujianguo@huawei.com>, Jiang Liu <jiang.liu@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, 17 Jul 2012, Luck, Tony wrote:

> > This suggests that a call to early_kmem_cache_node_alloc was not needed
> > because the per node structure already existed. Lets fix that instead.
>
> Perhaps by just having one API for users to call? It seems odd to force users
> to figure out whether they are called before some magic time during boot
> and use the "early...()" call. Shouldn't we hide this sort of detail from them?

The early_ calls are internal to the allocator and not exposed to the
user.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
