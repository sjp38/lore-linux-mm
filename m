Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D24216B0071
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 00:46:44 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5B4gK5f005002
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 22:42:20 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5B4kat4174788
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 22:46:36 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5B4kaOu029745
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 22:46:36 -0600
Date: Fri, 11 Jun 2010 10:16:32 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page cache
 control
Message-ID: <20100611044632.GD5191@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>
 <20100608155153.3749.31669.sendpatchset@L34Z31A.ibm.com>
 <4C10B3AF.7020908@redhat.com>
 <20100610142512.GB5191@balbir.in.ibm.com>
 <1276214852.6437.1427.camel@nimitz>
 <20100611105441.ee657515.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100611105441.ee657515.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Avi Kivity <avi@redhat.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-06-11 10:54:41]:

> On Thu, 10 Jun 2010 17:07:32 -0700
> Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> 
> > On Thu, 2010-06-10 at 19:55 +0530, Balbir Singh wrote:
> > > > I'm not sure victimizing unmapped cache pages is a good idea.
> > > > Shouldn't page selection use the LRU for recency information instead
> > > > of the cost of guest reclaim?  Dropping a frequently used unmapped
> > > > cache page can be more expensive than dropping an unused text page
> > > > that was loaded as part of some executable's initialization and
> > > > forgotten.
> > > 
> > > We victimize the unmapped cache only if it is unused (in LRU order).
> > > We don't force the issue too much. We also have free slab cache to go
> > > after.
> > 
> > Just to be clear, let's say we have a mapped page (say of /sbin/init)
> > that's been unreferenced since _just_ after the system booted.  We also
> > have an unmapped page cache page of a file often used at runtime, say
> > one from /etc/resolv.conf or /etc/passwd.
> > 
> 
> Hmm. I'm not fan of estimating working set size by calculation
> based on some numbers without considering history or feedback.
> 
> Can't we use some kind of feedback algorithm as hi-low-watermark, random walk
> or GA (or somehing more smart) to detect the size ?
>

Could you please clarify at what level you are suggesting size
detection? I assume it is outside the OS, right? 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
