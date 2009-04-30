Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D8C396B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 08:00:00 -0400 (EDT)
Received: by gxk20 with SMTP id 20so2627193gxk.14
        for <linux-mm@kvack.org>; Thu, 30 Apr 2009 04:59:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090429130430.4B11.A69D9226@jp.fujitsu.com>
References: <20090428090916.GC17038@localhost> <20090428120818.GH22104@mit.edu>
	 <20090429130430.4B11.A69D9226@jp.fujitsu.com>
Date: Thu, 30 Apr 2009 20:59:59 +0900
Message-ID: <2f11576a0904300459t61ae9619tcf8defacfc94f79@mail.gmail.com>
Subject: Re: Swappiness vs. mmap() and interactive response
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Theodore Tso <tytso@mit.edu>, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <peterz@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> test environment: no lvm, copy ext3 to ext3 (not mv), no change swappines=
s,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0CFQ is used, userland is Fedora10, mmo=
tm(2.6.30-rc1 + mm patch),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0CPU opteronx4, mem 4G
>
> mouse move lag: =A0 =A0 =A0 =A0 =A0 =A0 =A0 not happend
> window move lag: =A0 =A0 =A0 =A0 =A0 =A0 =A0not happend
> Mapped page decrease rapidly: not happend (I guess, these page stay in
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0active list on my system)
> page fault large latency: =A0 =A0 happend (latencytop display >1200ms)
>
>
> Then, I don't doubt vm replacement logic now.
> but I need more investigate.
> I plan to try following thing today and tommorow.
>
> =A0- XFS
> =A0- LVM
> =A0- another io scheduler (thanks Ted, good view point)
> =A0- Rik's new patch

hm, AS io-scheduler don't make such large latency on my environment.
Elladan, Can you try to AS scheduler? (adding boot option "elevator=3Das")

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
