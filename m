Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DFC4E8D0039
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 00:28:29 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp04.au.ibm.com (8.14.4/8.13.1) with ESMTP id p175N0XY005778
	for <linux-mm@kvack.org>; Mon, 7 Feb 2011 16:23:00 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p175SIsA1704154
	for <linux-mm@kvack.org>; Mon, 7 Feb 2011 16:28:23 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p175SITT014154
	for <linux-mm@kvack.org>; Mon, 7 Feb 2011 16:28:18 +1100
Date: Mon, 7 Feb 2011 10:57:44 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [LSF/MM TOPIC] memory control groups
Message-ID: <20110207052744.GG27729@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110117191359.GI2212@cmpxchg.org>
 <AANLkTim_eDn-BS5OwmdowXMX75XgFWdcUepMJ5YBX1R7@mail.gmail.com>
 <20110118174523.5c79a032.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110118174523.5c79a032.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2011-01-18 17:45:23]:

> On Tue, 18 Jan 2011 00:17:53 -0800
> Michel Lespinasse <walken@google.com> wrote:
> 
> 
> > > The per-memcg dirty accounting work e.g. allocates a bunch of new bits
> > > in pc->flags and I'd like to hash out if this leaves enough room for
> > > the structure packing I described, or whether we can come up with a
> > > different way of tracking state.
> > 
> > This is probably longer term, but I would love to get rid of the
> > duplication between global LRU and per-cgroup LRU. Global LRU could be
> > approximated by scanning all per-cgroup LRU lists (in mounts
> > proportional to the list lengths).
> > 
> 
> I can't answer why the design, which memory cgroup's meta-page has its own LRU
> rather than reusing page->lru, is selected at 1st implementation because I didn't
> join the birth of memcg. Does anyone remember the reason or discussion ? 
>

The discussions can be found on LKML, some happened during OLS.
Keeping local LRU and global LRU was very important because we wanted
to make sure global reclaim is not broken or affected. We can discuss
this further.
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
