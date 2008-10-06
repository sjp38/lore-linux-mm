Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28esmtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id m96GWhST001703
	for <linux-mm@kvack.org>; Mon, 6 Oct 2008 22:02:43 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m96GWhLX1347652
	for <linux-mm@kvack.org>; Mon, 6 Oct 2008 22:02:43 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m96GWg42015306
	for <linux-mm@kvack.org>; Tue, 7 Oct 2008 03:32:42 +1100
Date: Mon, 6 Oct 2008 22:02:38 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/6] memcg: allocate page_cgroup at boot (hunk fix)
Message-ID: <20081006163238.GC1202@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20081001165233.404c8b9c.kamezawa.hiroyu@jp.fujitsu.com> <20081001165603.a6e73c0d.kamezawa.hiroyu@jp.fujitsu.com> <20081002174945.4034cc9f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20081002174945.4034cc9f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-10-02 17:49:45]:

> Index: mmotm-2.6.27-rc7+/include/linux/mm_types.h
> ===================================================================
> --- mmotm-2.6.27-rc7+.orig/include/linux/mm_types.h
> +++ mmotm-2.6.27-rc7+/include/linux/mm_types.h
> @@ -94,10 +94,6 @@ struct page {
>  	void *virtual;			/* Kernel virtual address (NULL if
>  					   not kmapped, ie. highmem) */
>  #endif /* WANT_PAGE_VIRTUAL */
> -#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> -	unsigned long page_cgroup;
> -#endif
> -

Just FYI, this hunk fails for mmotm Oct 2nd, applied on top of
2.6.27-rc8, the space after the #endif is gone

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
