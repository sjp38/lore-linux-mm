Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA106B0038
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 18:06:07 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e20so89576895itc.0
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 15:06:07 -0700 (PDT)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id 37si183252otb.5.2016.09.14.15.05.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Sep 2016 15:05:52 -0700 (PDT)
Received: by mail-oi0-x232.google.com with SMTP id m11so43745722oif.1
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 15:05:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <8B91B5C5-4506-40CB-B7F0-0990A37F95AA@amazon.de>
References: <1466244679-23824-1-git-send-email-karahmed@amazon.de>
 <20160620082339.GC4340@dhcp22.suse.cz> <8B91B5C5-4506-40CB-B7F0-0990A37F95AA@amazon.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 14 Sep 2016 15:05:51 -0700
Message-ID: <CAPcyv4gQZ-=6SdsGc-YafcAUz0WWxtGuh56CPan1xqSkWbd9=A@mail.gmail.com>
Subject: Re: [PATCH] sparse: Track the boundaries of memory sections for
 accurate checks
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Raslan, KarimAllah" <karahmed@amazon.de>
Cc: Michal Hocko <mhocko@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Joe Perches <joe@perches.com>, Tejun Heo <tj@kernel.org>, "Liguori, Anthony" <aliguori@amazon.com>, "Schoenherr, Jan H." <jschoenh@amazon.de>

On Wed, Sep 14, 2016 at 2:40 PM, Raslan, KarimAllah <karahmed@amazon.de> wrote:
>
>
> On 6/20/16, 10:23 AM, "Michal Hocko" <mhocko@kernel.org> wrote:
>
>     On Sat 18-06-16 12:11:19, KarimAllah Ahmed wrote:
>     > When sparse memory model is used an array of memory sections is created to
>     > track each block of contiguous physical pages. Each element of this array
>     > contains PAGES_PER_SECTION pages. During the creation of this array the actual
>     > boundaries of the memory block is lost, so the whole block is either considered
>     > as present or not.
>     >
>     > pfn_valid() in the sparse memory configuration checks which memory sections the
>     > pfn belongs to then checks whether it's present or not. This yields sub-optimal
>     > results when the available memory doesn't cover the whole memory section,
>     > because pfn_valid will return 'true' even for the unavailable pfns at the
>     > boundaries of the memory section.
>
>     Please be more verbose of _why_ the patch is needed. Why those
>     "sub-optimal results" matter?
>
> Does this make sense to you ?

[ channeling my inner akpm ]

What's the user visible effect of this change?  What code is getting
tripped up by pfn_valid() being imprecise, and why is changing
pfn_valid() the preferred fix?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
