Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EDCB66B0253
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 13:25:36 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 63so35175266pfx.0
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 10:25:36 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id r5si43540930paa.190.2016.08.09.10.25.35
        for <linux-mm@kvack.org>;
        Tue, 09 Aug 2016 10:25:35 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [RFC 00/11] THP swap: Delay splitting THP during swapping out
References: <1470760673-12420-1-git-send-email-ying.huang@intel.com>
Date: Tue, 09 Aug 2016 10:25:34 -0700
In-Reply-To: <1470760673-12420-1-git-send-email-ying.huang@intel.com> (Ying
	Huang's message of "Tue, 9 Aug 2016 09:37:42 -0700")
Message-ID: <87k2fp4zxt.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi, All,

"Huang, Ying" <ying.huang@intel.com> writes:

> From: Huang Ying <ying.huang@intel.com>
>
> This patchset is based on 8/4 head of mmotm/master.
>
> This is the first step for Transparent Huge Page (THP) swap support.
> The plan is to delaying splitting THP step by step and avoid splitting
> THP finally during THP swapping out and swapping in.
>
> The advantages of THP swap support are:
>
> - Batch swap operations for THP to reduce lock acquiring/releasing,
>   including allocating/freeing swap space, adding/deleting to/from swap
>   cache, and writing/reading swap space, etc.
>
> - THP swap space read/write will be 2M sequence IO.  It is particularly
>   helpful for swap read, which usually are 4k random IO.
>
> - It will help memory fragmentation, especially when THP is heavily used
>   by the applications.  2M continuous pages will be free up after THP
>   swapping out.
>
> As the first step, in this patchset, the splitting huge page is
> delayed from almost the first step of swapping out to after allocating
> the swap space for THP and adding the THP into swap cache.  This will
> reduce lock acquiring/releasing for locks used for swap space and swap
> cache management.

For this patchset posting,

In general, I want to check the basic design with memory management
subsystem maintainers and developers.

For [RFC 01/11] swap: Add swap_cluster_list, it is a cleanup patch.  And
I think it should be useful independently.

I am not very confident about the memcg part, that is

[RFC 03/11] mm, memcg: Add swap_cgroup_iter iterator
[RFC 04/11] mm, memcg: Support to charge/uncharge multiple swap entries

Please help me to check it.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
