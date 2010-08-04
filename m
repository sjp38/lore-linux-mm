Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1ED68620138
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 08:06:36 -0400 (EDT)
Date: Wed, 4 Aug 2010 13:04:32 +0100
From: Chris Webb <chris@arachsys.com>
Subject: Re: Over-eager swapping
Message-ID: <20100804120430.GB23551@arachsys.com>
References: <AANLkTinnWQA-K6r_+Y+giEC9zs-MbY6GFs8dWadSq0kh@mail.gmail.com>
 <20100803033108.GA23117@arachsys.com>
 <AANLkTinjmZOOaq7FgwJOZ=UNGS8x8KtQWZg6nv7fqJMe@mail.gmail.com>
 <20100803042835.GA17377@localhost>
 <20100803214945.GA2326@arachsys.com>
 <20100804022148.GA5922@localhost>
 <AANLkTi=wRPXY9BTuoCe_sDCwhnRjmmwtAf_bjDKG3kXQ@mail.gmail.com>
 <20100804032400.GA14141@localhost>
 <20100804095811.GC2326@arachsys.com>
 <20100804114933.GA13527@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100804114933.GA13527@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Wu Fengguang <fengguang.wu@intel.com> writes:

> Maybe turn off KSM? It helps to isolate problems. It's a relative new
> and complex feature after all.

Good idea! I'll give that a go on one of the machines without swap at the
moment, re-add the swap with ksm turned off, and see what happens.

> > However, your suggestion is right that the CPU loads on these machines are
> > typically quite high. The large number of kvm virtual machines they run mean
> > thatl oads of eight or even sixteen in /proc/loadavg are not unusual, and
> > these are higher when there's swap than after it has been removed. I assume
> > this is mostly because of increased IO wait, as this number increases
> > significantly in top.
> 
> iowait = CPU (idle) waiting for disk IO
> 
> So iowait means not CPU load, but somehow disk load :)

Sorry, yes, I wrote very unclearly here. What I should have written is that
the load numbers are fairly high even without swap, when the IO wait figure
is pretty small. This is presumably normal CPU load from the guests.

The load average rises significantly when swap is added, but I think that
rise is due to an increase in processes waiting for IO (io wait %age
increases considerably) rather than extra CPU work. Presumably this is the
IO from swapping.

Cheers,

Chris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
