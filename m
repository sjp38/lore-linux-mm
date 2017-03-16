Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 286216B0038
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 15:39:04 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y17so109182944pgh.2
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 12:39:04 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0094.outbound.protection.outlook.com. [104.47.32.94])
        by mx.google.com with ESMTPS id 31si6226663pli.135.2017.03.16.12.39.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 12:39:03 -0700 (PDT)
Date: Thu, 16 Mar 2017 14:38:44 -0500
From: Alex Thorlton <alex.thorlton@hpe.com>
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
Message-ID: <20170316193844.GA110825@stormcage.americas.sgi.com>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, alex.thorlton@hpe.com

On Wed, Mar 15, 2017 at 04:59:59PM +0800, Aaron Lu wrote:
> v2 changes: Nothing major, only minor ones.
>  - rebased on top of v4.11-rc2-mmotm-2017-03-14-15-41;
>  - use list_add_tail instead of list_add to add worker to tlb's worker
>    list so that when doing flush, the first queued worker gets flushed
>    first(based on the comsumption that the first queued worker has a
>    better chance of finishing its job than those later queued workers);
>  - use bool instead of int for variable free_batch_page in function
>    tlb_flush_mmu_free_batches;
>  - style change according to ./scripts/checkpatch;
>  - reword some of the changelogs to make it more readable.
> 
> v1 is here:
> https://lkml.org/lkml/2017/2/24/245

I tested v1 on a Haswell system with 64 sockets/1024 cores/2048 threads
and 8TB of RAM, with a 1TB malloc.  The average free() time for a 1TB
malloc on a vanilla kernel was 41.69s, the patched kernel averaged
21.56s for the same test.

I am testing v2 now and will report back with results in the next day or
so.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
