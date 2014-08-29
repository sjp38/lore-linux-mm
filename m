Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 72CC36B0035
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 17:05:24 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id rd3so7343809pab.31
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 14:05:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z3si2385411pdj.12.2014.08.29.14.05.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Aug 2014 14:05:23 -0700 (PDT)
Date: Fri, 29 Aug 2014 14:05:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 7/7] mm/balloon_compaction: general cleanup
Message-Id: <20140829140521.ca9b1dc87c8bc4b075f5b083@linux-foundation.org>
In-Reply-To: <20140820150509.4194.24336.stgit@buzz>
References: <20140820150435.4194.28003.stgit@buzz>
	<20140820150509.4194.24336.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Cc: linux-mm@kvack.org, Rafael Aquini <aquini@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, linux-kernel@vger.kernel.org

On Wed, 20 Aug 2014 19:05:09 +0400 Konstantin Khlebnikov <k.khlebnikov@samsung.com> wrote:

> * move special branch for balloon migraion into migrate_pages
> * remove special mapping for balloon and its flag AS_BALLOON_MAP
> * embed struct balloon_dev_info into struct virtio_balloon
> * cleanup balloon_page_dequeue, kill balloon_page_free
> 

grump.

diff -puN include/linux/balloon_compaction.h~mm-balloon_compaction-general-cleanup-fix include/linux/balloon_compaction.h
--- a/include/linux/balloon_compaction.h~mm-balloon_compaction-general-cleanup-fix
+++ a/include/linux/balloon_compaction.h
@@ -145,7 +145,7 @@ static inline void
 balloon_page_insert(struct balloon_dev_info *balloon, struct page *page)
 {
 	__SetPageBalloon(page);
-	list_add(&page->lru, head);
+	list_add(&page->lru, &balloon->pages);
 }
 
 static inline void balloon_page_delete(struct page *page, bool isolated)


This obviously wasn't tested with CONFIG_BALLOON_COMPACTION=n.  Please
complete the testing of this patchset and let us know the result?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
