Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id F38A06B006C
	for <linux-mm@kvack.org>; Thu, 18 Dec 2014 16:26:22 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id k14so2791276wgh.29
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 13:26:22 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id hu10si13997001wjb.53.2014.12.18.13.26.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Dec 2014 13:26:22 -0800 (PST)
Date: Thu, 18 Dec 2014 13:26:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V3 0/4] Reducing parameters of alloc_pages* family of
 functions
Message-Id: <20141218132619.4e6b349d0aa1744c41f985c7@linux-foundation.org>
In-Reply-To: <1418400805-4661-1-git-send-email-vbabka@suse.cz>
References: <1418400805-4661-1-git-send-email-vbabka@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Fri, 12 Dec 2014 17:13:21 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:

> Vlastimil Babka (4):
>   mm: set page->pfmemalloc in prep_new_page()
>   mm, page_alloc: reduce number of alloc_pages* functions' parameters
>   mm: reduce try_to_compact_pages parameters
>   mm: microoptimize zonelist operations

That all looks pretty straightforward.  It would be nice to have a
summary of the code-size and stack-usage changes for the whole
patchset.

Can we move `struct alloc_context' into mm/internal.h?

I pity the poor schmuck who has to maintain this patchset for 2 months.
[2/4] already throws a large pile of rejects against page_alloc.c so
can you please refresh/retest/resend?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
