Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id D85736B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 16:07:46 -0400 (EDT)
Received: by igbhj9 with SMTP id hj9so3448372igb.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 13:07:46 -0700 (PDT)
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com. [15.216.225.55])
        by mx.google.com with ESMTPS id e38si16511359ioj.105.2015.04.27.13.07.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 13:07:46 -0700 (PDT)
Message-ID: <553E970E.2040406@hp.com>
Date: Mon, 27 Apr 2015 16:07:42 -0400
From: Waiman Long <waiman.long@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/13] x86: mm: Enable deferred struct page initialisation
 on x86-64
References: <1429722473-28118-1-git-send-email-mgorman@suse.de> <1429722473-28118-11-git-send-email-mgorman@suse.de> <20150422164500.121a355e6b578243cb3650e3@linux-foundation.org> <20150423092327.GJ14842@suse.de> <553A54C5.3060106@hp.com> <20150424152007.GD2449@suse.de> <553A93BB.1010404@hp.com> <20150425172859.GE2449@suse.de>
In-Reply-To: <20150425172859.GE2449@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>

On 04/25/2015 01:28 PM, Mel Gorman wrote:
> On Fri, Apr 24, 2015 at 03:04:27PM -0400, Waiman Long wrote:
>>>> Within a NUMA node, however, we can split the
>>>> memory initialization to 2 or more local CPUs if the memory size is
>>>> big enough.
>>>>
>>> I considered it but discarded the idea. It'd be more complex to setup and
>>> the two CPUs could simply end up contending on the same memory bus as
>>> well as contending on zone->lock.
>>>
>> I don't think we need that now. However, we may have to consider
>> this when one day even a single node can have TBs of memory unless
>> we move to a page size larger than 4k.
>>
> We'll cross that bridge when we come to it. I suspect there is more room
> for improvement in the initialisation that would be worth trying before
> resorting to more threads. With more threads there is a risk that we hit
> memory bus contention and a high risk that it actually is worse due to
> contending on zone->lock when freeing the pages.
>
> In the meantime, do you mind updating the before/after figures for your
> test machine with this series please?
>

I will test the latest patch once I got my hand on a 12TB machine.

Cheers,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
