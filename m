Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4F9FF6B009C
	for <linux-mm@kvack.org>; Sun,  5 Dec 2010 00:14:20 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp02.au.ibm.com (8.14.4/8.13.1) with ESMTP id oB559TtL028381
	for <linux-mm@kvack.org>; Sun, 5 Dec 2010 16:09:30 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB55EFcm2248752
	for <linux-mm@kvack.org>; Sun, 5 Dec 2010 16:14:15 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB55EErj007202
	for <linux-mm@kvack.org>; Sun, 5 Dec 2010 16:14:15 +1100
Date: Thu, 2 Dec 2010 12:31:04 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages
Message-ID: <20101202070103.GP2746@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20101130142509.4f49d452.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1012010859020.2849@router.home>
 <20101202102110.157F.A69D9226@jp.fujitsu.com>
 <20101202115036.1a4a42b5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20101202115036.1a4a42b5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm <kvm@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-12-02 11:50:36]:

> On Thu,  2 Dec 2010 10:22:16 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > On Tue, 30 Nov 2010, Andrew Morton wrote:
> > > 
> > > > > +#define UNMAPPED_PAGE_RATIO 16
> > > >
> > > > Well.  Giving 16 a name didn't really clarify anything.  Attentive
> > > > readers will want to know what this does, why 16 was chosen and what
> > > > the effects of changing it will be.
> > > 
> > > The meaning is analoguous to the other zone reclaim ratio. But yes it
> > > should be justified and defined.
> > > 
> > > > > Reviewed-by: Christoph Lameter <cl@linux.com>
> > > >
> > > > So you're OK with shoving all this flotsam into 100,000,000 cellphones?
> > > > This was a pretty outrageous patchset!
> > > 
> > > This is a feature that has been requested over and over for years. Using
> > > /proc/vm/drop_caches for fixing situations where one simply has too many
> > > page cache pages is not so much fun in the long run.
> > 
> > I'm not against page cache limitation feature at all. But, this is
> > too ugly and too destructive fast path. I hope this patch reduce negative
> > impact more.
> > 
> 
> And I think min_mapped_unmapped_pages is ugly. It should be
> "unmapped_pagecache_limit" or some because it's for limitation feature.
>

The feature will now be enabled with a CONFIG and boot parameter, I
find changing the naming convention now - it is already in use and
well known is not a good idea. THe name of the boot parameter can be
changed of-course. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
