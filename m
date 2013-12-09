Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f47.google.com (mail-qe0-f47.google.com [209.85.128.47])
	by kanga.kvack.org (Postfix) with ESMTP id C81DC6B00BB
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 11:17:39 -0500 (EST)
Received: by mail-qe0-f47.google.com with SMTP id t7so3055949qeb.34
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 08:17:39 -0800 (PST)
Received: from a9-50.smtp-out.amazonses.com (a9-50.smtp-out.amazonses.com. [54.240.9.50])
        by mx.google.com with ESMTP id r5si8594612qat.160.2013.12.09.08.17.33
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 08:17:38 -0800 (PST)
Date: Mon, 9 Dec 2013 16:17:32 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 2/7] mm/migrate: correct failure handling if
 !hugepage_migration_support()
In-Reply-To: <1386580248-22431-3-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <00000142d8263858-5c29199b-77e5-47a5-9db6-2ea6ea7c7fc8-000000@email.amazonses.com>
References: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com> <1386580248-22431-3-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Mon, 9 Dec 2013, Joonsoo Kim wrote:

> We should remove the page from the list if we fail without ENOSYS,
> since migrate_pages() consider error cases except -ENOMEM and -EAGAIN
> as permanent failure and it assumes that the page would be removed from
> the list. Without this patch, we could overcount number of failure.

Ok what does the patch do about this? I dont see any modifications. Remove
this part of the description?

> In addition, we should put back the new hugepage if
> !hugepage_migration_support(). If not, we would leak hugepage memory.

Ok looks like that is fixed by this patch.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
