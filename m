Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m967gQBG018259
	for <linux-mm@kvack.org>; Mon, 6 Oct 2008 13:12:26 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m967gQtL1429606
	for <linux-mm@kvack.org>; Mon, 6 Oct 2008 13:12:26 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m967gP1C009910
	for <linux-mm@kvack.org>; Mon, 6 Oct 2008 13:12:25 +0530
Date: Mon, 6 Oct 2008 13:12:23 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/6] atomic page_cgroup flags
Message-ID: <20081006074223.GA1202@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20081001165233.404c8b9c.kamezawa.hiroyu@jp.fujitsu.com> <20081001165513.7633c132.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20081001165513.7633c132.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-10-01 16:55:13]:

> This patch makes page_cgroup->flags to be atomic_ops and define
> functions (and macros) to access it.
> 
> Before trying to modify memory resource controller, this atomic operation
> on flags is necessary. Most of flags in this patch is for LRU and modfied
> under mz->lru_lock but we'll add another flags which is not for LRU soon.
> (lock_page_cgroup() will use LOCK bit on page_cgroup->flags)
> So we use atomic version here.
>

Seems quite straightforward

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
