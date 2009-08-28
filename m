Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 902B46B004D
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 11:08:33 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp04.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7SF8VnO002551
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 20:38:31 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7SF8UZW2240752
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 20:38:30 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7SF8UHH013741
	for <linux-mm@kvack.org>; Sat, 29 Aug 2009 01:08:30 +1000
Date: Fri, 28 Aug 2009 20:38:29 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 1/5] memcg: change for softlimit.
Message-ID: <20090828150829.GR4889@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com> <20090828132321.e4a497bb.kamezawa.hiroyu@jp.fujitsu.com> <20090828072007.GH4889@balbir.in.ibm.com> <20090828163523.e51678be.kamezawa.hiroyu@jp.fujitsu.com> <20090828132643.GM4889@balbir.in.ibm.com> <bfd50d44ff730c2720b882a81b7446c6.squirrel@webmail-b.css.fujitsu.com> <712c0209222358d9c7d1e33f93e21c30.squirrel@webmail-b.css.fujitsu.com> <20090828144648.GO4889@balbir.in.ibm.com> <b2d13270df033cc94ec4387e01c88c82.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <b2d13270df033cc94ec4387e01c88c82.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-29 00:06:23]:

> Balbir Singh wrote:
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-28
> > 23:40:56]:
> >
> >> KAMEZAWA Hiroyuki wrote:
> >> > Balbir Singh wrote:
> >> >> But Bob and Mike might need to set soft limits between themselves. if
> >> >> soft limit of gold is 1G and bob needs to be close to 750M and mike
> >> >> 250M, how do we do it without supporting what we have today?
> >> >>
> >> > Don't use hierarchy or don't use softlimit.
> >> > (I never think fine-grain  soft limit can be useful.)
> >> >
> >> > Anyway, I have to modify unnecessary hacks for res_counter of
> >> softlimit.
> >> > plz allow modification. that's bad.
> >> > I postpone RB-tree breakage problem, plz explain it or fix it by
> >> yourself.
> >> >
> >> I changed my mind....per-zone RB-tree is also broken ;)
> >>
> >> Why I don't like broken system is a function which a user can't
> >> know/calculate how-it-works is of no use in mission critical systems.
> >>
> >> I'd like to think how-to-fix it with better algorithm. Maybe RB-tree
> >> is not a choice.
> >>
> >
> > Soft limits are not meant for mission critical work :-) Soft limits is
> > best effort and not a guaranteed resource allocation mechanism. I've
> > mentioned in previous emails how we recover if we find the data is
> > stale
> >
> yes. but can you explain how selection will be done to users ?
> I can't.
>

>From a user point, we get what we set, but the timelines can be a
little longer. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
