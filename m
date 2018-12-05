Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 833AB6B7438
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 07:08:23 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o21so9783823edq.4
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 04:08:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f2sor11173858ede.19.2018.12.05.04.08.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 04:08:22 -0800 (PST)
Date: Wed, 5 Dec 2018 12:08:20 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 1/2] mm, pageblock: make sure pageblock won't exceed
 mem_sectioin
Message-ID: <20181205120820.3gbhfvxgmclvj3wu@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181205091905.27727-1-richard.weiyang@gmail.com>
 <20181205111513.GA23260@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181205111513.GA23260@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org

On Wed, Dec 05, 2018 at 11:15:13AM +0000, Mel Gorman wrote:
>On Wed, Dec 05, 2018 at 05:19:04PM +0800, Wei Yang wrote:
>> When SPARSEMEM is used, there is an indication that pageblock is not
>> allowed to exceed one mem_section. Current code doesn't have this
>> constrain explicitly.
>> 
>> This patch adds this to make sure it won't.
>> 
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>
>Is this even possible? This would imply that the section size is smaller
>than max order which would be quite a crazy selection for a sparesemem
>section size. A lot of assumptions on the validity of PFNs within a
>max-order boundary would be broken with such a section size. I'd be
>surprised if such a setup could even boot, let alone run.

pageblock_order has two definitions.

    #define pageblock_order        HUGETLB_PAGE_ORDER

    #define pageblock_order        (MAX_ORDER-1)

If CONFIG_HUGETLB_PAGE is not enabled, pageblock_order is related to
MAX_ORDER, which ensures it is smaller than section size.

If CONFIG_HUGETLB_PAGE is enabled, pageblock_order is not related to
MAX_ORDER. I don't see HUGETLB_PAGE_ORDER is ensured to be less than
section size. Maybe I missed it?

>
>-- 
>Mel Gorman
>SUSE Labs

-- 
Wei Yang
Help you, Help me
