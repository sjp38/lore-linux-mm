Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id C776D6B0033
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 09:40:33 -0400 (EDT)
Date: Thu, 15 Aug 2013 15:40:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [Bug] Reproducible data corruption on i5-3340M: Please revert
 53a59fc67!
Message-ID: <20130815134031.GC27864@dhcp22.suse.cz>
References: <52050382.9060802@gmail.com>
 <520BB225.8030807@gmail.com>
 <20130814174039.GA24033@dhcp22.suse.cz>
 <CA+55aFwAz7GdcB6nC0Th42y8eAM591sKO1=mYh5SWgyuDdHzcA@mail.gmail.com>
 <20130814182756.GD24033@dhcp22.suse.cz>
 <CA+55aFxB6Wyj3G3Ju8E7bjH-706vi3vysuATUZ13h1tdYbCbnQ@mail.gmail.com>
 <520C9E78.2020401@gmail.com>
 <CA+55aFy2D2hTc_ina1DvungsCL4WU2OTM=bnVb8sDyDcGVCBEQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFy2D2hTc_ina1DvungsCL4WU2OTM=bnVb8sDyDcGVCBEQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ben Tebulin <tebulin@googlemail.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>

On Thu 15-08-13 05:02:31, Linus Torvalds wrote:
> On Thu, Aug 15, 2013 at 2:25 AM, Ben Tebulin <tebulin@googlemail.com> wrote:
> >
> > I just cherry-picked e6c495a96ce0 into 3.9.11 and 3.7.10.
> > Unfortunately this does _not resolve_ my issue (too good to be true) :-(
> 
> Ho humm. I've found at least one other bug, but that one only affects
> hugepages. Do you perhaps have transparent hugepages enabled? But even
> then it looks quite unlikely.

__unmap_hugepage_range is hugetlb not THP if you had that one in mind.
And yes, it doesn't set the range which sounds buggy.

> I'll think about this some more. I'm not happy with how that
> particular whole TLB flushing hack was done, but I need to sleep on
> this.

I am looking into it as well, but there are high prio things which
preempt me a lot :/

Thanks for looking into it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
