Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 80F658D0039
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 00:28:24 -0500 (EST)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp05.in.ibm.com (8.14.4/8.13.1) with ESMTP id p175SIpr022097
	for <linux-mm@kvack.org>; Mon, 7 Feb 2011 10:58:18 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p175SIDL4395178
	for <linux-mm@kvack.org>; Mon, 7 Feb 2011 10:58:18 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p175SHjG008870
	for <linux-mm@kvack.org>; Mon, 7 Feb 2011 16:28:18 +1100
Date: Mon, 7 Feb 2011 10:56:08 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [LSF/MM TOPIC] memory control groups
Message-ID: <20110207052608.GF27729@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110117191359.GI2212@cmpxchg.org>
 <AANLkTin9EwgBRbmrDGcOKV35Z62xHb_T9Z4XPVVgxsao@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <AANLkTin9EwgBRbmrDGcOKV35Z62xHb_T9Z4XPVVgxsao@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>

* Michel Lespinasse <walken@google.com> [2011-02-06 07:45:05]:

> On Mon, Jan 17, 2011 at 11:14 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > on the MM summit, I would like to talk about the current state of
> > memory control groups, the features and extensions that are currently
> > being developed for it, and what their status is.
> >
> > I am especially interested in talking about the current runtime memory
> > overhead memcg comes with (1% of ram) and what we can do to shrink it.
> > [...]
> > Would other people be interested in discussing this?
> 
> Well, YES :)
> 
> In addition to what you mentioned, I believe it would be possible to
> avoid the duplication of global vs per-cgroup LRU lists. global
> scanning would translate into proportional scanning of all per-cgroup
> lists. If we could get that done, it would IMO become reasonable to
> integrate back the remaining few page_cgroup fields into struct page
> itself...
>

We thought about the duplication and proportial scanning quite a bit
prior to final design and integration, but it does not scale well as
cgroups increase in number. I would also like to discuss things
like accounting shared pages, etc. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
