Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19BC2C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 07:56:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEDCD21917
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 07:56:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oOeYqfUt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEDCD21917
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44E538E0081; Fri,  8 Feb 2019 02:56:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D9D18E0002; Fri,  8 Feb 2019 02:56:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DBB18E0081; Fri,  8 Feb 2019 02:56:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C51B58E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 02:56:56 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 71so1871109plf.19
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 23:56:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=33aqc7VxCmQrf2zs2FpPkA7KtnfR/GRdMJWgpUgJpEM=;
        b=s0M4YvwbgIYheFH4WHwD1iEWR0p+kXLcEumtR6EW8t2x/NJopxGIyruxx2iezA+cTJ
         EUreDLrPS9Gt7sfKHf+fDRX/w9Kd1aTgAmYBFaYvRegPJPL7ZpLZUYMWVa+7y2kt3F2Z
         7bqqBvEySCIIFf7/cRcMYPSPyPhafoQirAkcKd+IKeAq6Qjnte9WvdcISc8JM9eXOhIr
         67igG7ApgvW9UK1qUzGD6ixMVTkSctvhhNLNBkPhO/JDOAwK1jg4OUO6I/RhrUhIG93e
         s8/a01eRvECpZutIQ0/n92nWR1f9NwbODgDUKO1uZbKWX9u32n3+41UYg1lQmmHBQa/v
         mBdg==
X-Gm-Message-State: AHQUAuY6ItpN73hJyXSCKyKN36Y/DopK0tV8WTzvmhwaXGSWsln9/Khw
	7B2bmLCVQICKtxhsQp9CisANVG8lsocAP8sbxZ1WP/OycvvfrcCup10izHZ5ozQnSRUEV8qncy6
	wdwhiu2fXFrR2j8xQhczZks/0I/VKUO3awtk98bp/2xzVG9RygRO/qh57xEm9F6rvZTxKoKQqni
	W0xQpvyxVLDkeI2myCT7ZtHKIYFYsM6DH1nMZ1LsGFIpNcLg+tLBcRRfjdH/1HsYXR7AiIi2thi
	K0uPBflViSQbAKKqGLEP+3HeM+0x1O9WfvEU8wwvAYRHR7U2gq5McHPVcrKVqIPx6RoPGA6Hl+0
	0kXASS5f/ai3oEgQUjGCklHd1T8pL0jhc5PExM77x3JhcrQhsG4jz6TvW988B7qNzjRzbBXr59l
	h
X-Received: by 2002:a65:64c8:: with SMTP id t8mr8760602pgv.31.1549612616253;
        Thu, 07 Feb 2019 23:56:56 -0800 (PST)
X-Received: by 2002:a65:64c8:: with SMTP id t8mr8760542pgv.31.1549612615078;
        Thu, 07 Feb 2019 23:56:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549612615; cv=none;
        d=google.com; s=arc-20160816;
        b=Ib9F0aXNZVQ4K3na5Qi+UKQ8/qywxrPOZPd+OKjklJj+15TuL+77rBIzAOzeND5F+O
         jG4r0z8BJ4b/IEfq3WkYvx3h99jAmrG7JhUGWveVkviOudmwvG84OnMA/FNg0581lpYP
         ok4scJoggON5oDxrlnmS03P2/zRljXPxcHKbezx9o2A0oz68fHyQNodFXAySMzhOPm7U
         1zB/KJgPkIp9LZlloeDm/l1lC+nXbYPAU6QFTJBHau7abNkZi/0HFtTWIde2A74uyoUz
         OwIbnDK3gYkRt4ByjoJBgBqy1DohEGL+F5lJbcnp/EGeyNKFG2ufmTTSTnnmmiUz04+8
         NqaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=33aqc7VxCmQrf2zs2FpPkA7KtnfR/GRdMJWgpUgJpEM=;
        b=eHwjXFNuqqHl6Ml45r0q4Lrsyps0wIVSwLySPmigTDGT1i7MzzRtsVogbkivVBXRfW
         XlDMMW7Te0wse0r7UNg002+2m+LTQ/PjcSf4oM6CysAsno1UVREQGuWQrqd1CrtTPt64
         HIzYUcL7pXUR3Uzin9ZEUN0gybFWg5RGjdDJHsGkuFWWbXG1w+zon7nL+fcx8edswhYy
         BOIWzxqKeS0kogbzyMxcIaDhULRACSzNSor1dyuW5jOUDY0e0D84GNddFSS0GlPncBbY
         2XblFWshxXU3++mRA7l7GJ85G8IxSNQYt/TCGItRoIOuEPg2VO6J5x7EGqDTJkW1cqW9
         N1UQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oOeYqfUt;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a16sor1617505pgw.48.2019.02.07.23.56.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 23:56:55 -0800 (PST)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oOeYqfUt;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=33aqc7VxCmQrf2zs2FpPkA7KtnfR/GRdMJWgpUgJpEM=;
        b=oOeYqfUtXBNrVgo+VeodEVVR034PVDJLhgzdbme81C0PIxX2ttKG4gV4sD+b5UGM6n
         xpO2VvX1Wq6ajdWaoT2zI7Sw2gCqnmz1FeklNnKA1Lnqko7hzAwP99nbtTJax/xZpbMx
         K6kNidvmaJuQ1QVoKxxOPw2EBhE8Pz/cuYxoN5xYyebzyDJZRAx6eZ2uoZN8MasOZWrh
         0b734phPIp3ld30v/CXZnD8ZXHmtmgTRmTq+aRRt+cV1BBn34gN+7jX+pqEGPQzuVhUr
         uazvaGrsI5gxRaaW8hnzecpNaEWJ/JctpA9szJ+xEeyX9mrdfJyddmqisjabYbTjlSKn
         m3Hw==
X-Google-Smtp-Source: AHgI3IYo9MNT56RXdhRr+J3mZ3gjZXndch8d3O7H0eXplSlfFA8QPMUsfVhX1gtcwwJ3Gse7G9c1+g==
X-Received: by 2002:a63:c56:: with SMTP id 22mr4014447pgm.44.1549612614688;
        Thu, 07 Feb 2019 23:56:54 -0800 (PST)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id h64sm2642610pfc.142.2019.02.07.23.56.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 23:56:53 -0800 (PST)
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
Subject: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Date: Thu,  7 Feb 2019 23:56:48 -0800
Message-Id: <20190208075649.3025-2-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190208075649.3025-1-jhubbard@nvidia.com>
References: <20190208075649.3025-1-jhubbard@nvidia.com>
MIME-Version: 1.0
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

This is just one symptom of the larger design problem: filesystems do not
actually support get_user_pages() being called on their pages, and letting
hardware write directly to those pages--even though that patter has been
going on since about 2005 or so.

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
Cc: Jan Kara <jack@suse.cz>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>

Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/mm.h | 24 ++++++++++++++
 mm/swap.c          | 82 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 106 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80bb6408fe73..809b7397d41e 100644
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
diff --git a/mm/swap.c b/mm/swap.c
index 4929bc1be60e..7c42ca45bb89 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -133,6 +133,88 @@ void put_pages_list(struct list_head *pages)
 }
 EXPORT_SYMBOL(put_pages_list);
 
+typedef int (*set_dirty_func)(struct page *page);
+
+static void __put_user_pages_dirty(struct page **pages,
+				   unsigned long npages,
+				   set_dirty_func sdf)
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
 /*
  * get_kernel_pages() - pin kernel pages in memory
  * @kiov:	An array of struct kvec structures
-- 
2.20.1

