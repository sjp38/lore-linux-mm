Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EFED92802FE
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 21:41:53 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j79so227725388pfj.9
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 18:41:53 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id l193si5526580pge.598.2017.07.27.18.41.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 18:41:52 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id e3so1873826pfc.5
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 18:41:51 -0700 (PDT)
Date: Fri, 28 Jul 2017 10:42:04 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3 1/2] mm: migrate: prevent racy access to
 tlb_flush_pending
Message-ID: <20170728014204.GA26322@jagdpanzerIV.localdomain>
References: <20170727114015.3452-1-namit@vmware.com>
 <20170727114015.3452-2-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727114015.3452-2-namit@vmware.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: linux-mm@kvack.org, sergey.senozhatsky@gmail.com, minchan@kernel.org, nadav.amit@gmail.com, mgorman@suse.de, riel@redhat.com, luto@kernel.org, stable@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On (07/27/17 04:40), Nadav Amit wrote:
[..]
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -159,7 +159,7 @@ void dump_mm(const struct mm_struct *mm)
>  		mm->numa_next_scan, mm->numa_scan_offset, mm->numa_scan_seq,
>  #endif
>  #if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
> -		mm->tlb_flush_pending,
> +		atomic_read(&mm->tlb_flush_pending),
>  #endif

can we use mm_tlb_flush_pending() here and get rid of ifdef-s?

/* I understand that this a -stable patch, so we can do it in a
separate patch. */

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
