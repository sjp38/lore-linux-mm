Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 77FD6830F1
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 23:39:19 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id 30so19861871uab.1
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 20:39:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g128si11354732ybg.234.2016.08.29.20.39.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 20:39:18 -0700 (PDT)
Date: Mon, 29 Aug 2016 20:39:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] thp: reduce usage of huge zero page's atomic counter
Message-Id: <20160829203916.6a2b45845e8fb0c356cac17d@linux-foundation.org>
In-Reply-To: <36b76a95-5025-ac64-0862-b98b2ebdeaf7@intel.com>
References: <b7e47f2c-8aac-156a-f627-a50db31220f8@intel.com>
	<20160829155021.2a85910c3d6b16a7f75ffccd@linux-foundation.org>
	<36b76a95-5025-ac64-0862-b98b2ebdeaf7@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-kernel@vger.kernel.org

On Tue, 30 Aug 2016 11:09:15 +0800 Aaron Lu <aaron.lu@intel.com> wrote:

> >> Case used for test on Haswell EP:
> >> usemem -n 72 --readonly -j 0x200000 100G
> >> Which spawns 72 processes and each will mmap 100G anonymous space and
> >> then do read only access to that space sequentially with a step of 2MB.
> >>
> >> perf report for base commit:
> >>     54.03%  usemem   [kernel.kallsyms]   [k] get_huge_zero_page
> >> perf report for this commit:
> >>      0.11%  usemem   [kernel.kallsyms]   [k] mm_get_huge_zero_page
> > 
> > Does this mean that overall usemem runtime halved?
> 
> Sorry for the confusion, the above line is extracted from perf report.
> It shows the percent of CPU cycles executed in a specific function.
> 
> The above two perf lines are used to show get_huge_zero_page doesn't
> consume that much CPU cycles after applying the patch.
> 
> > 
> > Do we have any numbers for something which is more real-wordly?
> 
> Unfortunately, no real world numbers.
> 
> We think the global atomic counter could be an issue for performance
> so I'm trying to solve the problem.

So, umm, we don't actually know if the patch is useful to anyone?

Some more measurements would help things along, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
