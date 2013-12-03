Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9A56B007B
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 18:41:42 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id j5so6142768qaq.5
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 15:41:41 -0800 (PST)
Received: from mail-yh0-x236.google.com (mail-yh0-x236.google.com [2607:f8b0:4002:c01::236])
        by mx.google.com with ESMTPS id 4si18855066qeq.131.2013.12.03.15.41.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 15:41:41 -0800 (PST)
Received: by mail-yh0-f54.google.com with SMTP id z12so10710858yhz.41
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 15:41:41 -0800 (PST)
Date: Tue, 3 Dec 2013 15:41:38 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, show_mem: Remove SHOW_MEM_FILTER_PAGE_COUNT
In-Reply-To: <20131203145721.GQ11295@suse.de>
Message-ID: <alpine.DEB.2.02.1312031541240.5946@chino.kir.corp.google.com>
References: <20131016104228.GM11028@suse.de> <alpine.DEB.2.02.1310161809470.12062@chino.kir.corp.google.com> <20131203145721.GQ11295@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Russell King <linux@arm.linux.org.uk>, James Bottomley <jejb@parisc-linux.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 3 Dec 2013, Mel Gorman wrote:

> Commit 4b59e6c4 (mm, show_mem: suppress page counts in non-blockable
> contexts) introduced SHOW_MEM_FILTER_PAGE_COUNT to suppress PFN walks
> on large memory machines. Commit c78e9363 (mm: do not walk all of system
> memory during show_mem) avoided a PFN walk in the generic show_mem helper
> which removes the requirement for SHOW_MEM_FILTER_PAGE_COUNT in that case.
> 
> This patch removes PFN walkers from the arch-specific implementations that
> report on a per-node or per-zone granularity. ARM and unicore32 still do
> a PFN walk as they report memory usage on each bank which is a much finer
> granularity where the debugging information may still be of use. As the
> remaining arches doing PFN walks have relatively small amounts of memory,
> this patch simply removes SHOW_MEM_FILTER_PAGE_COUNT.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: David Rientjes <rientjes@google.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
