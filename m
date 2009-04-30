Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 18BA46B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 09:46:16 -0400 (EDT)
Date: Thu, 30 Apr 2009 06:46:33 -0700
From: Elladan <elladan@eskimo.com>
Subject: Re: Swappiness vs. mmap() and interactive response
Message-ID: <20090430134632.GA31807@eskimo.com>
References: <20090428090916.GC17038@localhost> <20090428120818.GH22104@mit.edu> <20090429130430.4B11.A69D9226@jp.fujitsu.com> <2f11576a0904300459t61ae9619tcf8defacfc94f79@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2f11576a0904300459t61ae9619tcf8defacfc94f79@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Theodore Tso <tytso@mit.edu>, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <peterz@infradead.org>, Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 30, 2009 at 08:59:59PM +0900, KOSAKI Motohiro wrote:
> > test environment: no lvm, copy ext3 to ext3 (not mv), no change swappiness,
> >                  CFQ is used, userland is Fedora10, mmotm(2.6.30-rc1 + mm patch),
> >                  CPU opteronx4, mem 4G
> >
> > mouse move lag:               not happend
> > window move lag:              not happend
> > Mapped page decrease rapidly: not happend (I guess, these page stay in
> >                                          active list on my system)
> > page fault large latency:     happend (latencytop display >1200ms)
> >
> >
> > Then, I don't doubt vm replacement logic now.
> > but I need more investigate.
> > I plan to try following thing today and tommorow.
> >
> >  - XFS
> >  - LVM
> >  - another io scheduler (thanks Ted, good view point)
> >  - Rik's new patch
> 
> hm, AS io-scheduler don't make such large latency on my environment.
> Elladan, Can you try to AS scheduler? (adding boot option "elevator=as")

I switched at runtime with /sys/block/sd[ab]/queue/scheduler, using Rik's
second patch for page replacement.  It was hard to tell if this made much
difference in latency, as reported by latencytop.  Both schedulers sometimes
show outliers up to 1400msec or so, and the average latency looks like it may
be similar.

Thanks,
Elladan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
