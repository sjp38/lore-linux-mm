Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4D66B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 15:32:21 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id at1so789865iec.28
        for <linux-mm@kvack.org>; Thu, 29 May 2014 12:32:21 -0700 (PDT)
Received: from mail-ig0-x22c.google.com (mail-ig0-x22c.google.com [2607:f8b0:4001:c05::22c])
        by mx.google.com with ESMTPS id z5si21710358igl.7.2014.05.29.12.32.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 May 2014 12:32:20 -0700 (PDT)
Received: by mail-ig0-f172.google.com with SMTP id uy17so4188141igb.5
        for <linux-mm@kvack.org>; Thu, 29 May 2014 12:32:20 -0700 (PDT)
Date: Thu, 29 May 2014 12:32:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] CMA: use MIGRATE_SYNC in alloc_contig_range()
In-Reply-To: <1401344750-3684-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.02.1405291229330.28183@chino.kir.corp.google.com>
References: <1401344750-3684-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Thu, 29 May 2014, Joonsoo Kim wrote:

> Before commit 'mm, compaction: embed migration mode in compact_control'
> from David is merged, alloc_contig_range() used sync migration,
> instead of sync_light migration. This doesn't break anything currently
> because page isolation doesn't have any difference with sync and
> sync_light, but it could in the future, so change back as it was.
> 
> And pass cc->mode to migrate_pages(), instead of passing MIGRATE_SYNC
> to migrate_pages().
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: David Rientjes <rientjes@google.com>

Should probably be renamed 
mm-compaction-embed-migration-mode-in-compact_control-fix-fix though since 
it's based on another patch in -mm that properly does the s/sync/mode/ 
conversion for CMA.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
