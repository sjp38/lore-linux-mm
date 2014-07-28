Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id AEF8A6B0037
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 05:37:34 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id n12so7148599wgh.9
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 02:37:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cb19si12518822wib.85.2014.07.28.02.37.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Jul 2014 02:37:26 -0700 (PDT)
Date: Mon, 28 Jul 2014 10:37:19 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: fix page_alloc.c kernel-doc warnings
Message-ID: <20140728093719.GN10819@suse.de>
References: <53D56BF5.5030002@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <53D56BF5.5030002@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Linux MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Jul 27, 2014 at 02:15:33PM -0700, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix kernel-doc warnings and function name in mm/page_alloc.c:
> 
> Warning(..//mm/page_alloc.c:6074): No description found for parameter 'pfn'
> Warning(..//mm/page_alloc.c:6074): No description found for parameter 'mask'
> Warning(..//mm/page_alloc.c:6074): Excess function parameter 'start_bitidx' description in 'get_pfnblock_flags_mask'
> Warning(..//mm/page_alloc.c:6102): No description found for parameter 'pfn'
> Warning(..//mm/page_alloc.c:6102): No description found for parameter 'mask'
> Warning(..//mm/page_alloc.c:6102): Excess function parameter 'start_bitidx' description in 'set_pfnblock_flags_mask'
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> Cc: Mel Gorman <mgorman@suse.de>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
