Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 02CC26B0032
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 08:37:24 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id f12so509013wgh.15
        for <linux-mm@kvack.org>; Thu, 15 Aug 2013 05:37:23 -0700 (PDT)
Message-ID: <520CCB80.6090508@gmail.com>
Date: Thu, 15 Aug 2013 14:37:20 +0200
From: Ben Tebulin <tebulin@googlemail.com>
MIME-Version: 1.0
Subject: Re: [Bug] Reproducible data corruption on i5-3340M: Please revert
 53a59fc67!
References: <52050382.9060802@gmail.com> <520BB225.8030807@gmail.com> <20130814174039.GA24033@dhcp22.suse.cz> <CA+55aFwAz7GdcB6nC0Th42y8eAM591sKO1=mYh5SWgyuDdHzcA@mail.gmail.com> <20130814182756.GD24033@dhcp22.suse.cz> <CA+55aFxB6Wyj3G3Ju8E7bjH-706vi3vysuATUZ13h1tdYbCbnQ@mail.gmail.com> <520C9E78.2020401@gmail.com> <CA+55aFy2D2hTc_ina1DvungsCL4WU2OTM=bnVb8sDyDcGVCBEQ@mail.gmail.com>
In-Reply-To: <CA+55aFy2D2hTc_ina1DvungsCL4WU2OTM=bnVb8sDyDcGVCBEQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>

Am 15.08.2013 14:02, schrieb Linus Torvalds:
>> I just cherry-picked e6c495a96ce0 into 3.9.11 and 3.7.10.
>> Unfortunately this does _not resolve_ my issue (too good to be true) :-(
> Ho humm. I've found at least one other bug, but that one only affects
> hugepages. Do you perhaps have transparent hugepages enabled? 

I was using the Ubuntu mainline Kernel config:

   ben@n179 ~/p/linux.git> cat .config | grep TRANSPARENT_HUG
   CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
   CONFIG_TRANSPARENT_HUGEPAGE=y
   # CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
   CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y

> I'll think about this some more. I'm not happy with how that
> particular whole TLB flushing hack was done, but I need to sleep on
> this.

Thanks!

Being an end user having only a very limited understanding of the
internals behind this issue, I really appreciate any support I receive
from people who do. :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
