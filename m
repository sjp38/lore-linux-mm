Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D9E246B01E5
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 08:24:21 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o51CBK35012017
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 08:11:20 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o51CN1NY114624
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 08:23:01 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o51CN1fX028021
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 08:23:01 -0400
Received: from balbir-laptop ([9.77.209.155])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id o51CN0fb027985
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 08:23:00 -0400
Resent-Message-ID: <20100601122258.GG2804@balbir.in.ibm.com>
Resent-To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Date: Tue, 1 Jun 2010 15:34:52 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][3/3] memcg swap accounts remove experimental
Message-ID: <20100601100452.GD2804@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100601182406.1ede3581.kamezawa.hiroyu@jp.fujitsu.com>
 <20100601182720.f1562de6.kamezawa.hiroyu@jp.fujitsu.com>
 <20100601182936.36ea72b9.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100601182936.36ea72b9.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-06-01 18:29:36]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> It has benn a year since we changed swap_map[] to indicates SWAP_HAS_CACHE.
> By that, memcg's swap accounting has been very stable and it seems
> it can be maintained. 
> 
> So, I'd like to remove EXPERIMENTAL from the config.

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
