Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 50AD66B004D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 07:29:29 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n59C7dlC004236
	for <linux-mm@kvack.org>; Tue, 9 Jun 2009 08:07:39 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n59C4sc9242554
	for <linux-mm@kvack.org>; Tue, 9 Jun 2009 08:04:54 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n59C4rNx014014
	for <linux-mm@kvack.org>; Tue, 9 Jun 2009 08:04:54 -0400
Date: Tue, 9 Jun 2009 17:34:51 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: fix mem_cgroup_isolate_lru_page to use the same
	rotate logic at busy path
Message-ID: <20090609120451.GD6648@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090609181505.4083a213.kamezawa.hiroyu@jp.fujitsu.com> <20090609182253.009c98a3.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090609182253.009c98a3.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-06-09 18:22:53]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> This patch tries to fix memcg's lru rotation sanity...make memcg use
> the same logic as global LRU does.
> 
> Now, at __isolate_lru_page() retruns -EBUSY, the page is rotated to
> the tail of LRU in global LRU's isolate LRU pages. But in memcg,
> it's not handled. This makes memcg do the same behavior as global LRU
> and rotate LRU in the page is busy.
> 
> Note: __isolate_lru_page() is not isolate_lru_page() and it's just used
> in sc->isolate_pages() logic.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
