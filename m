Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 48C936B006E
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 12:01:38 -0400 (EDT)
Received: by qcyk17 with SMTP id k17so8823169qcy.1
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 09:01:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 79si8686796qgo.20.2015.04.16.09.01.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 09:01:36 -0700 (PDT)
Message-ID: <552FDCD4.70108@redhat.com>
Date: Thu, 16 Apr 2015 12:01:24 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] mm: migrate: Batch TLB flushing when unmapping pages
 for migration
References: <1429179766-26711-1-git-send-email-mgorman@suse.de> <1429179766-26711-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1429179766-26711-5-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>
Cc: Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On 04/16/2015 06:22 AM, Mel Gorman wrote:
> Page reclaim batches multiple TLB flushes into one IPI and this patch teaches
> page migration to also batch any necessary flushes. MMtests has a THP scale
> microbenchmark that deliberately fragments memory and then allocates THPs
> to stress compaction. It's not a page reclaim benchmark and recent kernels
> avoid excessive compaction but this patch reduced system CPU usage
> 
>                4.0.0       4.0.0
>             baseline batchmigrate-v1
> User          970.70     1012.24
> System       2067.48     1840.00
> Elapsed      1520.63     1529.66
> 
> Note that this particular workload was not TLB flush intensive with peaks
> in interrupts during the compaction phase. The 4.0 kernel peaked at 345K
> interrupts/second, the kernel that batches reclaim TLB entries peaked at
> 13K interrupts/second and this patch peaked at 10K interrupts/second.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
