Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 51E336B005A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 13:53:18 -0400 (EDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH] mm/slub: fix a BUG_ON() when offlining a memory node
 and CONFIG_SLUB_DEBUG is on
Date: Tue, 17 Jul 2012 17:53:16 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F1936AB66@ORSMSX104.amr.corp.intel.com>
References: <1342543816-10853-1-git-send-email-jiang.liu@huawei.com>
 <alpine.DEB.2.00.1207171237320.15177@router.home>
In-Reply-To: <alpine.DEB.2.00.1207171237320.15177@router.home>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Jiang Liu <liuj97@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Jianguo Wu <wujianguo@huawei.com>, Jiang Liu <jiang.liu@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> This suggests that a call to early_kmem_cache_node_alloc was not needed
> because the per node structure already existed. Lets fix that instead.

Perhaps by just having one API for users to call? It seems odd to force use=
rs
to figure out whether they are called before some magic time during boot
and use the "early...()" call. Shouldn't we hide this sort of detail from t=
hem?

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
