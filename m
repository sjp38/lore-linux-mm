Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5766CC4360F
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 21:36:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0ADBA20652
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 21:36:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fs1CsZCl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0ADBA20652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 191F58E0005; Fri,  8 Mar 2019 16:36:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11C2A8E0002; Fri,  8 Mar 2019 16:36:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAF1B8E0005; Fri,  8 Mar 2019 16:36:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A52DD8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 16:36:46 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id b12so21650871pgj.7
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 13:36:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kDKTJmGRrB2DVmVkF369QsCrmEvxOyKIOnMGmStFbjc=;
        b=nnWRjqCB4lg0nW700ITvT4GB3hpmH9I01YFTTcx8LXNDiXiA2qyIdnq41wx+Xic0ko
         4s9HQXMheeSaMmMV3oAiBWMtZYmdDEliQYM7g9P/UbIODjhNRuJjUi1TGu1VYQwOBb7e
         zTUUGiJEe4ABWWB//WkawrHsm2+Jlgac2zTIBQN5OEVL/yeN64miLcavA+ukI47bF1/L
         ptabtn2phxV/OmieSR4/n/0RdV8H4ltNCW0yP6e8MoIJF7U8fU3tGdlXBT8YC7aQD2xX
         HYWaqVf+oqd4WSJ31BhzVKCOglRBu19vPHZtu6uj/lzX6GKf97henIrOsSPMkOZNg7+o
         jhwA==
X-Gm-Message-State: APjAAAUzZmE7Gx1Jip3czhSZOLfi7o/rw7mzbwlxQrEIezGe+LOxA9QV
	HMjZ7DgNfbpCumYvfU+1WIofoBCD7cqUW5JpyYWBaB+uNHA+Y3eWnUHiE+qtgdjIUKbePHfFusz
	KEZx2cxrpNqHoPs+p0EJWQTGhlcRG/7/g+Y3Rv4zHKNi9X3984dYQSQM/8XtxPP+s2FZGs9QMai
	8yorm+7C/ci4IAXk2Zln+MBoxJ3KmQzigwU3AZbh+ByV/7HlAs0ZUnwjK2MtyqhXmISpgj2ds0X
	guSn+izKchKtuGOMZ+SchN7Dh4yashz6muJ8HbJ2MoelHyajlTolXvbzAdYpH5O8lGACK4AQy48
	cuP8ZrGBjRfxGonqLJ/7UjqBZFuHrRyUHsbkcQTQa67F1SVzhAk/Pi+rJdeJMtFhL/uenpG96z7
	U
X-Received: by 2002:a17:902:b404:: with SMTP id x4mr21201854plr.232.1552081006320;
        Fri, 08 Mar 2019 13:36:46 -0800 (PST)
X-Received: by 2002:a17:902:b404:: with SMTP id x4mr21201797plr.232.1552081005442;
        Fri, 08 Mar 2019 13:36:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552081005; cv=none;
        d=google.com; s=arc-20160816;
        b=P3f+tfNr8gfDjSFG3TZGMcV0GZIEW3cqkxQ3A331RSSkhP/YgDI6BPbTDRskyb9oHP
         xfrE4HSLhjTW/BwU05LBV6wyNQ6fXGPhVXKJbHj77TOquO8qzIkHgoGXtW6teRhujENn
         0vJSPljJ6jstazk5qJLeQh8Wv90WUByl6B1Qc/jbAG392Zk5MTFN3YIGAdGEeSwgGABu
         E6LWPVwjyQ/ZSCzk4YiCxXDRrdrrMKfkQVV5C5NSaYhlTk5GzwY5Dx0V1NRGMv0VeCb3
         xcnHAK1SmEBuEUAPiUKmonqCgly7O4T4DYIbiHo7vJCpaFhfFukGw6M2273R1gJwuOrX
         zwlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=kDKTJmGRrB2DVmVkF369QsCrmEvxOyKIOnMGmStFbjc=;
        b=eGvKpn6Vg6LHu6zH2thEIeOVhtnlqkrKkvqBgFhKiBZoD7uoKM/IugS3/TfwWnl5rW
         TD2raaE154VcfF9Og9yYRBFmFq/vHmVYvLTMxUv5EjBYiWCWeGVemdt6VPzOv/8YmM1G
         Bg3LK1Wjr2FZ0O4Ic/6pqzsFwyXrPRpwszTZfqwqMdq7b/2r7EQjCWoNbAnpC+xMkIAk
         OzBELengKdVuwjJUYAVlMldciiLVwynozRoZC2rJyLLFjMwYyOgihAt8zaxsTJRCJfWq
         OtK2DGrov7DFi4CBN3vJ73srOOYi1ws/AXc3toTgt0CkdWUiCnpRts7XDCaZQ29jz7DR
         /zdg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fs1CsZCl;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h1sor14386976plh.28.2019.03.08.13.36.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 13:36:45 -0800 (PST)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fs1CsZCl;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=kDKTJmGRrB2DVmVkF369QsCrmEvxOyKIOnMGmStFbjc=;
        b=fs1CsZClBj/tPusa5tzCdpVn9k4H831T/6g0t2ayB41nLJFQYyQKkY3OSx4jbis2FT
         VZxqNzdFlqhM4K2niXutB9uVA2ugJpJgsQKExfM4d+53RVYsl6dVRyj/jSrrXRn3DuLO
         1d+v8UrIIWEvGusGNWYVsTP0prolwNn8XkQgDGNaWsRLwoT2t9fn3jur3rRNRoOH2B9F
         YJq07WHRFZmeGrzcabAym1Jqs7ANZz9utF4WxaUXOFWdlBX/V/GRZNj6JnsVIKG0hB0t
         g4TmRGOe/ZUnWo+nR1czQaDxeT3bdgmw2wklm0LDBe0AZ5lOiuAZno6T+WrQZqIm4ZPn
         jb3A==
X-Google-Smtp-Source: APXvYqwBT3c+yxcqZogCJP6Pgjl6XxolMZFjfPf2ee4HvtbNq06N5dzwgW5FdnBCSeaa20T/qf19qQ==
X-Received: by 2002:a17:902:59c1:: with SMTP id d1mr20579787plj.324.1552081005077;
        Fri, 08 Mar 2019 13:36:45 -0800 (PST)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id c2sm11803665pfd.159.2019.03.08.13.36.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 13:36:44 -0800 (PST)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jerome Glisse <jglisse@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH v4 1/1] mm: introduce put_user_page*(), placeholder versions
Date: Fri,  8 Mar 2019 13:36:33 -0800
Message-Id: <20190308213633.28978-2-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190308213633.28978-1-jhubbard@nvidia.com>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

Introduces put_user_page(), which simply calls put_page().
This provides a way to update all get_user_pages*() callers,
so that they call put_user_page(), instead of put_page().

Also introduces put_user_pages(), and a few dirty/locked variations,
as a replacement for release_pages(), and also as a replacement
for open-coded loops that release multiple pages.
These may be used for subsequent performance improvements,
via batching of pages to be released.

This is the first step of fixing a problem (also described in [1] and
[2]) with interactions between get_user_pages ("gup") and filesystems.

Problem description: let's start with a bug report. Below, is what happens
sometimes, under memory pressure, when a driver pins some pages via gup,
and then marks those pages dirty, and releases them. Note that the gup
documentation actually recommends that pattern. The problem is that the
filesystem may do a writeback while the pages were gup-pinned, and then the
filesystem believes that the pages are clean. So, when the driver later
marks the pages as dirty, that conflicts with the filesystem's page
tracking and results in a BUG(), like this one that I experienced:

    kernel BUG at /build/linux-fQ94TU/linux-4.4.0/fs/ext4/inode.c:1899!
    backtrace:
        ext4_writepage
        __writepage
        write_cache_pages
        ext4_writepages
        do_writepages
        __writeback_single_inode
        writeback_sb_inodes
        __writeback_inodes_wb
        wb_writeback
        wb_workfn
        process_one_work
        worker_thread
        kthread
        ret_from_fork

...which is due to the file system asserting that there are still buffer
heads attached:

        ({                                                      \
                BUG_ON(!PagePrivate(page));                     \
                ((struct buffer_head *)page_private(page));     \
        })

Dave Chinner's description of this is very clear:

    "The fundamental issue is that ->page_mkwrite must be called on every
    write access to a clean file backed page, not just the first one.
    How long the GUP reference lasts is irrelevant, if the page is clean
    and you need to dirty it, you must call ->page_mkwrite before it is
    marked writeable and dirtied. Every. Time."

This is just one symptom of the larger design problem: real filesystems
that actually write to a backing device, do not actually support
get_user_pages() being called on their pages, and letting hardware write
directly to those pages--even though that pattern has been going on since
about 2005 or so.

The steps are to fix it are:

1) (This patch): provide put_user_page*() routines, intended to be used
   for releasing pages that were pinned via get_user_pages*().

2) Convert all of the call sites for get_user_pages*(), to
   invoke put_user_page*(), instead of put_page(). This involves dozens of
   call sites, and will take some time.

3) After (2) is complete, use get_user_pages*() and put_user_page*() to
   implement tracking of these pages. This tracking will be separate from
   the existing struct page refcounting.

4) Use the tracking and identification of these pages, to implement
   special handling (especially in writeback paths) when the pages are
   backed by a filesystem.

[1] https://lwn.net/Articles/774411/ : "DMA and get_user_pages()"
[2] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"

Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Christopher Lameter <cl@linux.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>

Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>    # docs
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/mm.h | 24 ++++++++++++++
 mm/gup.c           | 82 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 106 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5801ee849f36..353035c8b115 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -993,6 +993,30 @@ static inline void put_page(struct page *page)
 		__put_page(page);
 }
 
+/**
+ * put_user_page() - release a gup-pinned page
+ * @page:            pointer to page to be released
+ *
+ * Pages that were pinned via get_user_pages*() must be released via
+ * either put_user_page(), or one of the put_user_pages*() routines
+ * below. This is so that eventually, pages that are pinned via
+ * get_user_pages*() can be separately tracked and uniquely handled. In
+ * particular, interactions with RDMA and filesystems need special
+ * handling.
+ *
+ * put_user_page() and put_page() are not interchangeable, despite this early
+ * implementation that makes them look the same. put_user_page() calls must
+ * be perfectly matched up with get_user_page() calls.
+ */
+static inline void put_user_page(struct page *page)
+{
+	put_page(page);
+}
+
+void put_user_pages_dirty(struct page **pages, unsigned long npages);
+void put_user_pages_dirty_lock(struct page **pages, unsigned long npages);
+void put_user_pages(struct page **pages, unsigned long npages);
+
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
 #define SECTION_IN_PAGE_FLAGS
 #endif
diff --git a/mm/gup.c b/mm/gup.c
index f84e22685aaa..37085b8163b1 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -28,6 +28,88 @@ struct follow_page_context {
 	unsigned int page_mask;
 };
 
+typedef int (*set_dirty_func_t)(struct page *page);
+
+static void __put_user_pages_dirty(struct page **pages,
+				   unsigned long npages,
+				   set_dirty_func_t sdf)
+{
+	unsigned long index;
+
+	for (index = 0; index < npages; index++) {
+		struct page *page = compound_head(pages[index]);
+
+		if (!PageDirty(page))
+			sdf(page);
+
+		put_user_page(page);
+	}
+}
+
+/**
+ * put_user_pages_dirty() - release and dirty an array of gup-pinned pages
+ * @pages:  array of pages to be marked dirty and released.
+ * @npages: number of pages in the @pages array.
+ *
+ * "gup-pinned page" refers to a page that has had one of the get_user_pages()
+ * variants called on that page.
+ *
+ * For each page in the @pages array, make that page (or its head page, if a
+ * compound page) dirty, if it was previously listed as clean. Then, release
+ * the page using put_user_page().
+ *
+ * Please see the put_user_page() documentation for details.
+ *
+ * set_page_dirty(), which does not lock the page, is used here.
+ * Therefore, it is the caller's responsibility to ensure that this is
+ * safe. If not, then put_user_pages_dirty_lock() should be called instead.
+ *
+ */
+void put_user_pages_dirty(struct page **pages, unsigned long npages)
+{
+	__put_user_pages_dirty(pages, npages, set_page_dirty);
+}
+EXPORT_SYMBOL(put_user_pages_dirty);
+
+/**
+ * put_user_pages_dirty_lock() - release and dirty an array of gup-pinned pages
+ * @pages:  array of pages to be marked dirty and released.
+ * @npages: number of pages in the @pages array.
+ *
+ * For each page in the @pages array, make that page (or its head page, if a
+ * compound page) dirty, if it was previously listed as clean. Then, release
+ * the page using put_user_page().
+ *
+ * Please see the put_user_page() documentation for details.
+ *
+ * This is just like put_user_pages_dirty(), except that it invokes
+ * set_page_dirty_lock(), instead of set_page_dirty().
+ *
+ */
+void put_user_pages_dirty_lock(struct page **pages, unsigned long npages)
+{
+	__put_user_pages_dirty(pages, npages, set_page_dirty_lock);
+}
+EXPORT_SYMBOL(put_user_pages_dirty_lock);
+
+/**
+ * put_user_pages() - release an array of gup-pinned pages.
+ * @pages:  array of pages to be marked dirty and released.
+ * @npages: number of pages in the @pages array.
+ *
+ * For each page in the @pages array, release the page using put_user_page().
+ *
+ * Please see the put_user_page() documentation for details.
+ */
+void put_user_pages(struct page **pages, unsigned long npages)
+{
+	unsigned long index;
+
+	for (index = 0; index < npages; index++)
+		put_user_page(pages[index]);
+}
+EXPORT_SYMBOL(put_user_pages);
+
 static struct page *no_page_table(struct vm_area_struct *vma,
 		unsigned int flags)
 {
-- 
2.21.0

