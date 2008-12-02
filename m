Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id mB24YBsd029415
	for <linux-mm@kvack.org>; Tue, 2 Dec 2008 15:34:11 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB24ZZUg310134
	for <linux-mm@kvack.org>; Tue, 2 Dec 2008 15:35:35 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB24ZZTw030460
	for <linux-mm@kvack.org>; Tue, 2 Dec 2008 15:35:35 +1100
Date: Tue, 2 Dec 2008 10:05:31 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [mmotm][PATCH 1/4]
	replacement-for-memcg-simple-migration-handling.patch
Message-ID: <20081202043531.GB28197@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20081202131723.806f1724.kamezawa.hiroyu@jp.fujitsu.com> <20081202131840.6d797997.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20081202131840.6d797997.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hugh@veritas.com" <hugh@veritas.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-12-02 13:18:40]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, management of "charge" under page migration is done under following
> manner. (Assume migrate page contents from oldpage to newpage)
> 
>  before
>   - "newpage" is charged before migration.
>  at success.
>   - "oldpage" is uncharged at somewhere(unmap, radix-tree-replace)
>  at failure
>   - "newpage" is uncharged.
>   - "oldpage" is charged if necessary (*1)
> 
> But (*1) is not reliable....because of GFP_ATOMIC.
>

Kamezawa,

You did share page migration test cases with me, but I would really
like to see a page migration test scenario or rather a set of test
scenarios for the memory controller. Sudhir has added some LTP test
cases, but for now I would be satisfied with Documentation updates for
testing the various memory controller features (sort of build a
regression set of cases in documented form and automate it later). I
can start with what I have, I would request you to update the
migration cases and any other case you have. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
