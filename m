Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8D4746B010C
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 03:17:45 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id a1so11778939wgh.6
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 00:17:45 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id r3si7361194wix.83.2014.11.03.00.17.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Nov 2014 00:17:44 -0800 (PST)
Date: Mon, 3 Nov 2014 09:17:39 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 -next 00/10] mm: improve usage of the i_mmap lock
Message-ID: <20141103081739.GY23531@worktop.programming.kicks-ass.net>
References: <1414697657-1678-1-git-send-email-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414697657-1678-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, hughd@google.com, riel@redhat.com, mgorman@suse.de, mingo@kernel.org, linux-kernel@vger.kernel.org, dbueso@suse.de, linux-mm@kvack.org

On Thu, Oct 30, 2014 at 12:34:07PM -0700, Davidlohr Bueso wrote:
> 
> Davidlohr Bueso (10):
>   mm,fs: introduce helpers around the i_mmap_mutex
>   mm: use new helper functions around the i_mmap_mutex
>   mm: convert i_mmap_mutex to rwsem
>   mm/rmap: share the i_mmap_rwsem
>   uprobes: share the i_mmap_rwsem
>   mm/xip: share the i_mmap_rwsem
>   mm/memory-failure: share the i_mmap_rwsem
>   mm/mremap: share the i_mmap_rwsem
>   mm/nommu: share the i_mmap_rwsem
>   mm/hugetlb: share the i_mmap_rwsem
> 

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
