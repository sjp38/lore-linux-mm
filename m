Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8D7186B007B
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 03:35:36 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so6843261pde.41
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 00:35:36 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ek3si9812532pbd.25.2013.12.10.00.35.32
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 00:35:34 -0800 (PST)
Date: Tue, 10 Dec 2013 17:38:25 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 2/7] mm/migrate: correct failure handling if
 !hugepage_migration_support()
Message-ID: <20131210083825.GB24992@lge.com>
References: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1386580248-22431-3-git-send-email-iamjoonsoo.kim@lge.com>
 <00000142d8263858-5c29199b-77e5-47a5-9db6-2ea6ea7c7fc8-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00000142d8263858-5c29199b-77e5-47a5-9db6-2ea6ea7c7fc8-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Mon, Dec 09, 2013 at 04:17:32PM +0000, Christoph Lameter wrote:
> On Mon, 9 Dec 2013, Joonsoo Kim wrote:
> 
> > We should remove the page from the list if we fail without ENOSYS,
> > since migrate_pages() consider error cases except -ENOMEM and -EAGAIN
> > as permanent failure and it assumes that the page would be removed from
> > the list. Without this patch, we could overcount number of failure.
> 
> Ok what does the patch do about this? I dont see any modifications. Remove
> this part of the description?

Description is slightly wrong.
Following is correct one.

"We should remove the page from the list if we fail *with* ENOSYS,"

And this patch do this by adding putback_active_hugepage(hpage)
on ENOSYS case.

> 
> > In addition, we should put back the new hugepage if
> > !hugepage_migration_support(). If not, we would leak hugepage memory.
> 
> Ok looks like that is fixed by this patch.
> 
> Acked-by: Christoph Lameter <cl@linux.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
