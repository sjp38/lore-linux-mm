Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 088836B0082
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 12:44:42 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id up15so1475096pbc.10
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 09:44:42 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id iz5si42268360pbd.242.2013.12.06.09.44.41
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 09:44:41 -0800 (PST)
Message-ID: <52A20CA9.2040303@intel.com>
Date: Fri, 06 Dec 2013 09:43:05 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: NUMA? bisected performance regression 3.11->3.12
References: <528E8FCE.1000707@intel.com> <20131126103223.GG5285@suse.de>
In-Reply-To: <20131126103223.GG5285@suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Kevin Hilman <khilman@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, Paul Bolle <paul.bollee@gmail.com>, Zlatko Calusic <zcalusic@bitsync.net>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On 11/26/2013 02:32 AM, Mel Gorman wrote:
> On Thu, Nov 21, 2013 at 02:57:18PM -0800, Dave Hansen wrote:
>> I'm running an open/close microbenchmark from the will-it-scale set:
>>> https://github.com/antonblanchard/will-it-scale/blob/master/tests/open1.c
>>
>> I was seeing some weird symptoms on 3.12 vs 3.11.  The throughput in
>> that test was going from down from 50 million to 35 million.
>>
>> The profiles show an increase in cpu time in _raw_spin_lock_irq.  The
>> profiles pointed to slub code that hasn't been touched in quite a while.
>>  I bisected it down to:
> 
> Dave, do you mind retesting this against "[RFC PATCH 0/5] Memory compaction
> efficiency improvements" please? I have not finished reviewing the series
> yet but patch 3 mentions lower allocation success rates with Johannes'
> patch and notes that it is unlikely to be a bug with the patch itself.

Sorry for the delay.  I lost monster box for a few days...

That series didn't look to have much of an effect.  Before/after numbers
coming out of that open1 test were both ~35M.  If it helped, it was in
the noise.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
