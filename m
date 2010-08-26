Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6136C6B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 04:51:23 -0400 (EDT)
Date: Thu, 26 Aug 2010 09:51:05 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: compaction: trying to understand the code
Message-ID: <20100826085105.GB20944@csn.ul.ie>
References: <20100819160006.GG6805@barrios-desktop> <AA3F2D89535A431DB91FE3032EDCB9EA@rainbow> <20100820053447.GA13406@localhost> <20100820093558.GG19797@csn.ul.ie> <AANLkTimVmoomDjGMCfKvNrS+v-mMnfeq6JDZzx7fjZi+@mail.gmail.com> <20100822153121.GA29389@barrios-desktop> <20100822232316.GA339@localhost> <AANLkTim8c5C+vH1HUx-GsScirmnVoJXenLST1qQgk2bp@mail.gmail.com> <C06122FE6B6044BD94C8A632B205D909@rainbow> <AANLkTikwZtaMioEOnwTJhs-PkXWeaZhv-hYXG13n=OBX@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <AANLkTikwZtaMioEOnwTJhs-PkXWeaZhv-hYXG13n=OBX@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Iram Shahzad <iram.shahzad@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 23, 2010 at 06:10:02PM +0900, Minchan Kim wrote:
> On Mon, Aug 23, 2010 at 12:03 PM, Iram Shahzad
> <iram.shahzad@jp.fujitsu.com> wrote:
> >> Iram. How do you execute test_app?
> >>
> >> 1) synchronous test
> >> 1.1 start test_app
> >> 1.2 wait test_app job done (ie, wait memory is fragment)
> >> 1.3 echo 1 > /proc/sys/vm/compact_memory
> >>
> >> 2) asynchronous test
> >> 2.1 start test_app
> >> 2.2 not wait test_app job done
> >> 2.3 echo 1 > /proc/sys/vm/compact_memory(Maybe your test app and
> >> compaction were executed parallel)
> >
> > It's synchronous.
> > First I confirm that the test app has completed its fragmentation work
> > by looking at the printf output. Then only I run echo 1 >
> > /proc/sys/vm/compact_memory.
> >
> > After completing fragmentation work, my test app sleeps in a useless while
> > loop
> > which I think is not important.
> 
> Thanks. It seems to be not any other processes which is entering
> direct reclaiming.
> I tested your test_app but failed to reproduce your problem.
> Actually I suspected some leak of decrease NR_ISOLATE_XXX but my
> system worked well.
> And I couldn't find the point as just code reviewing. If it really
> was, Mel found it during his stress test.
> 

My test machines have been tied up which has delayed me reviewing these
patches. I reran standardish compaction stress tests and didn't spot a
NR_ISOLATE_XXX. While none of those tests depend on the proc trigger,
they share the core logic so I don't think we're looking at a leak issue
and all the difficulty is in too_many_isolated()

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
