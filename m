Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 33DAE6B01F1
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 01:16:18 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7J5Fpmm012260
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 01:15:51 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7J5GGAQ1523862
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 01:16:16 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7J5GCTI023172
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 01:16:16 -0400
Date: Thu, 19 Aug 2010 10:46:10 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: Over-eager swapping
Message-ID: <20100819051610.GI28417@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100804032400.GA14141@localhost>
 <20100804095811.GC2326@arachsys.com>
 <20100804114933.GA13527@localhost>
 <20100804120430.GB23551@arachsys.com>
 <20100818143801.GA9086@localhost>
 <20100818144655.GX2370@arachsys.com>
 <20100818152103.GA11268@localhost>
 <1282147034.77481.33.camel@useless.localdomain>
 <20100818155825.GA2370@arachsys.com>
 <alpine.DEB.2.00.1008181112510.6294@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1008181112510.6294@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Chris Webb <chris@arachsys.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <cl@linux-foundation.org> [2010-08-18 11:13:03]:

> On Wed, 18 Aug 2010, Chris Webb wrote:
> 
> > > != 0.  And even then, zone reclaim should only reclaim file pages, not
> > > anon.  In theory...
> >
> > Hi. This is zero on all our machines:
> >
> > # sysctl vm.zone_reclaim_mode
> > vm.zone_reclaim_mode = 0
> 
> Set it to 1.
>

Isn't that bad in terms of how we treat the cost of remote node
allocations? Is local zone_reclaim() always a good thing or is it
something for chris to try and see if that helps his situation?

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
