Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 198116B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 05:06:42 -0400 (EDT)
Received: by wiclp12 with SMTP id lp12so11499078wic.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 02:06:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eu3si3214715wic.47.2015.09.02.02.06.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Sep 2015 02:06:41 -0700 (PDT)
Subject: Re: Can we disable transparent hugepages for lack of a legitimate use
 case please?
References: <BLUPR02MB1698DD8F0D1550366489DF8CCD620@BLUPR02MB1698.namprd02.prod.outlook.com>
 <CALYGNiOg_Zq8Fz-VWskH7LVGdExuq=03+56dpCsDiZ6eAq2A4Q@mail.gmail.com>
 <55DC3BD4.6020602@suse.cz>
 <alpine.DEB.2.10.1509011522470.11913@chino.kir.corp.google.com>
 <CALYGNiNQBbV8BOVyBUFYHO8i2Hx15T_Zbb+efKMLH5KR93ZQMw@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55E6BC1E.5080300@suse.cz>
Date: Wed, 2 Sep 2015 11:06:38 +0200
MIME-Version: 1.0
In-Reply-To: <CALYGNiNQBbV8BOVyBUFYHO8i2Hx15T_Zbb+efKMLH5KR93ZQMw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, David Rientjes <rientjes@google.com>
Cc: James Hartshorn <jhartshorn@connexity.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

On 2.9.2015 10:55, Konstantin Khlebnikov wrote:
> On Wed, Sep 2, 2015 at 1:26 AM, David Rientjes <rientjes@google.com> wrote:
>> On Tue, 25 Aug 2015, Vlastimil Babka wrote:
>>
>>>> THP works very well when system has a lot of free memory.
>>>> Probably default should be weakened to "only if we have tons of free
>>>> memory".
>>>> For example allocate THP pages atomically, only if buddy allocator already
>>>> has huge pages. Also them could be pre-zeroed in background.
>>>
>>> I've been proposing series that try to move more THP allocation activity from
>>> the page faults into khugepaged, but no success yet.
>>>
>>> Maybe we should just start with changing the default of
>>> /sys/kernel/mm/transparent_hugepage/defrag to "madvise".
>>
>> I would need to revert this internally to avoid performance degradation, I
>> believe others would report the same.
> 
> What about adding new mode "guess" -- something between always and madvise?
> 
> In this mode kernel tries to avoid performance impact for non-madvised vmas and
> allocates 0-order pages if hugepages are not available right now.
> (for example do allocations with GFP_NOWAIT)

That's exactly what happens when
/sys/kernel/mm/transparent_hugepage/defrag is set to "madvise".

> I think we'll get all benefits without losing performance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
