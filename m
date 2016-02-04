Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4B53D4403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 01:02:26 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id w123so33396030pfb.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 22:02:26 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id m23si14331879pfi.250.2016.02.03.22.02.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Feb 2016 22:02:25 -0800 (PST)
Date: Thu, 4 Feb 2016 15:02:21 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm, hugetlb: don't require CMA for runtime gigantic pages
Message-ID: <20160204060221.GA14877@js1304-P5Q-DELUXE>
References: <1454521811-11409-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454521811-11409-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Luiz Capitulino <lcapitulino@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@techsingularity.net>, Davidlohr Bueso <dave@stgolabs.net>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>

On Wed, Feb 03, 2016 at 06:50:11PM +0100, Vlastimil Babka wrote:
> Commit 944d9fec8d7a ("hugetlb: add support for gigantic page allocation at
> runtime") has added the runtime gigantic page allocation via
> alloc_contig_range(), making this support available only when CONFIG_CMA is
> enabled. Because it doesn't depend on MIGRATE_CMA pageblocks and the
> associated infrastructure, it is possible with few simple adjustments to
> require only CONFIG_MEMORY_ISOLATION instead of full CONFIG_CMA.
> 
> After this patch, alloc_contig_range() and related functions are available
> and used for gigantic pages with just CONFIG_MEMORY_ISOLATION enabled. Note
> CONFIG_CMA selects CONFIG_MEMORY_ISOLATION. This allows supporting runtime
> gigantic pages without the CMA-specific checks in page allocator fastpaths.

You need to set CONFIG_COMPACTION or CONFIG_CMA to use
isolate_migratepages_range() and others in alloc_contig_range().

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
