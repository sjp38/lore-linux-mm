Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9FD186B004A
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 00:22:36 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp02.in.ibm.com (8.14.4/8.13.1) with ESMTP id oB15MNWE023670
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 10:52:23 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB15MNYR4186272
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 10:52:23 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB15MMiA020847
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 10:52:23 +0530
Date: Wed, 1 Dec 2010 10:52:18 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] Refactor zone_reclaim
Message-ID: <20101201052218.GK2746@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20101130101126.17475.18729.stgit@localhost6.localdomain6>
 <20101130101520.17475.79978.stgit@localhost6.localdomain6>
 <20101201102329.89b96c54.kamezawa.hiroyu@jp.fujitsu.com>
 <20101201044634.GF2746@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20101201044634.GF2746@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kvm <kvm@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* Balbir Singh <balbir@linux.vnet.ibm.com> [2010-12-01 10:16:34]:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-12-01 10:23:29]:
> 
> > On Tue, 30 Nov 2010 15:45:55 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > Refactor zone_reclaim, move reusable functionality outside
> > > of zone_reclaim. Make zone_reclaim_unmapped_pages modular
> > > 
> > > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > Why is this min_mapped_pages based on zone (IOW, per-zone) ?
> >
> 
> Kamezawa-San, this has been the design before the refactoring (it is
> based on zone_reclaim_mode and reclaim based on top of that).  I am
> reusing bits of existing technology. The advantage of it being
> per-zone is that it integrates well with kswapd. 
>

My local MTA failed to deliver the message, trying again. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
