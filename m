Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 27A429000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 15:51:12 -0400 (EDT)
Date: Tue, 26 Apr 2011 12:47:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: readahead and oom
Message-Id: <20110426124743.e58d9746.akpm@linux-foundation.org>
In-Reply-To: <20110426092029.GA27053@localhost>
References: <BANLkTin8mE=DLWma=U+CdJaQW03X2M2W1w@mail.gmail.com>
	<20110426055521.GA18473@localhost>
	<BANLkTik8k9A8N8CPk+eXo9c_syxJFRyFCA@mail.gmail.com>
	<BANLkTim0MNgqeh1KTfvpVFuAvebKyQV8Hg@mail.gmail.com>
	<20110426062535.GB19717@localhost>
	<BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
	<20110426063421.GC19717@localhost>
	<BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
	<20110426092029.GA27053@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>

On Tue, 26 Apr 2011 17:20:29 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> Pass __GFP_NORETRY|__GFP_NOWARN for readahead page allocations.
> 
> readahead page allocations are completely optional. They are OK to
> fail and in particular shall not trigger OOM on themselves.

I have distinct recollections of trying this many years ago, finding
that it caused problems then deciding not to do it.  But I can't find
an email trail and I don't remember the reasons :(

If the system is so stressed for memory that the oom-killer might get
involved then the readahead pages may well be getting reclaimed before
the application actually gets to use them.  But that's just an aside.

Ho hum.  The patch *seems* good (as it did 5-10 years ago ;)) but there
may be surprising side-effects which could be exposed under heavy
testing.  Testing which I'm sure hasn't been performed...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
