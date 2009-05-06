Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 726D66B003D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 07:04:57 -0400 (EDT)
Date: Wed, 6 May 2009 20:04:24 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Swappiness vs. mmap() and interactive response
In-Reply-To: <2f11576a0904300459t61ae9619tcf8defacfc94f79@mail.gmail.com>
References: <20090429130430.4B11.A69D9226@jp.fujitsu.com> <2f11576a0904300459t61ae9619tcf8defacfc94f79@mail.gmail.com>
Message-Id: <20090506200413.7EBE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Theodore Tso <tytso@mit.edu>, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <peterz@infradead.org>, Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> > test environment: no lvm, copy ext3 to ext3 (not mv), no change swappiness,
> >         CFQ is used, userland is Fedora10, mmotm(2.6.30-rc1 + mm patch),
> >         CPU opteronx4, mem 4G
> >
> > mouse move lag:        not happend
> > window move lag:       not happend
> > Mapped page decrease rapidly: not happend (I guess, these page stay in
> >                     active list on my system)
> > page fault large latency:   happend (latencytop display >1200ms)
> >
> >
> > Then, I don't doubt vm replacement logic now.
> > but I need more investigate.
> > I plan to try following thing today and tommorow.
> >
> > - XFS
> > - LVM
> > - another io scheduler (thanks Ted, good view point)
> > - Rik's new patch
> 
> hm, AS io-scheduler don't make such large latency on my environment.
> Elladan, Can you try to AS scheduler? (adding boot option "elevator=as")

second test result:
read dev(sda): SSD, lvm+XFS
write dev(sdb): HDD, lvm+XFS

the result is the same of ext3 without lvm. Thus I think
XFS isn't guilty.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
