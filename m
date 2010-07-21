Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 21FD36B02A3
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 09:34:27 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6LDYOl6001356
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 21 Jul 2010 22:34:25 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C544F45DE51
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 22:34:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A0A8D45DE4D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 22:34:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 858481DB803E
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 22:34:24 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 41DF01DB8037
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 22:34:24 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] memcg: sc.nr_to_reclaim should be initialized
In-Reply-To: <20100716102557.GE13117@csn.ul.ie>
References: <20100716191256.736C.A69D9226@jp.fujitsu.com> <20100716102557.GE13117@csn.ul.ie>
Message-Id: <20100721223414.8713.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 21 Jul 2010 22:34:23 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
List-ID: <linux-mm.kvack.org>

> On Fri, Jul 16, 2010 at 07:13:31PM +0900, KOSAKI Motohiro wrote:
> > Currently, mem_cgroup_shrink_node_zone() initialize sc.nr_to_reclaim as 0.
> > It mean shrink_zone() only scan 32 pages and immediately return even if
> > it doesn't reclaim any pages.
> > 
> 
> Do you mean it immediately returns once one page is reclaimed? i.e. this
> check
> 
>                if (nr_reclaimed >= nr_to_reclaim && priority < DEF_PRIORITY)
>                         break;

Strictly speaking, once SWAP_CLUSTER_MAX batch is scanned. no need
to reclaim pages at all.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
