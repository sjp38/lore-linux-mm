Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id DD16D6B025F
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 02:48:46 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p17so9523531wmd.5
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 23:48:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 42si3578755wrb.112.2017.07.26.23.48.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 23:48:45 -0700 (PDT)
Date: Thu, 27 Jul 2017 07:48:43 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2 1/2] mm: migrate: prevent racy access to
 tlb_flush_pending
Message-ID: <20170727064843.zp6mt67olxbkrfpu@suse.de>
References: <20170726150214.11320-1-namit@vmware.com>
 <20170726150214.11320-2-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170726150214.11320-2-namit@vmware.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: linux-mm@kvack.org, nadav.amit@gmail.com, riel@redhat.com, luto@kernel.org, stable@vger.kernel.org

On Wed, Jul 26, 2017 at 08:02:13AM -0700, Nadav Amit wrote:
> From: Nadav Amit <nadav.amit@gmail.com>
> 
> Setting and clearing mm->tlb_flush_pending can be performed by multiple
> threads, since mmap_sem may only be acquired for read in
> task_numa_work(). If this happens, tlb_flush_pending might be cleared
> while one of the threads still changes PTEs and batches TLB flushes.
> 
> This can lead to the same race between migration and
> change_protection_range() that led to the introduction of
> tlb_flush_pending. The result of this race was data corruption, which
> means that this patch also addresses a theoretically possible data
> corruption.
> 
> An actual data corruption was not observed, yet the race was
> was confirmed by adding assertion to check tlb_flush_pending is not set
> by two threads, adding artificial latency in change_protection_range()
> and using sysctl to reduce kernel.numa_balancing_scan_delay_ms.
> 
> Fixes: 20841405940e ("mm: fix TLB flush race between migration, and
> change_protection_range")
> 
> Cc: stable@vger.kernel.org
> 
> Signed-off-by: Nadav Amit <namit@vmware.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
