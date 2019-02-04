Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1458AC282D7
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 05:21:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B283E217D9
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 05:21:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rhV20tUO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B283E217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E34E8E0032; Mon,  4 Feb 2019 00:21:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06C798E001C; Mon,  4 Feb 2019 00:21:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFF8B8E0032; Mon,  4 Feb 2019 00:21:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A92A8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 00:21:43 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id p4so9593488pgj.21
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 21:21:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=33aqc7VxCmQrf2zs2FpPkA7KtnfR/GRdMJWgpUgJpEM=;
        b=I0JjD6DX1l/tVD0Qb8a83clvHYVXNF5jlcqjYZgEDsABpgrrd4JSYFvjDnDw03LhM4
         aFrV21Zk5Ig+9BqFT0MxPedBj5CM0JsKa6dP5Azkd/qby7zpwWLcz7BBZWTHkwZCcIP+
         mjCy5pi0ADYuNpLQp9AlUbLvXwqbqsX5kkDQcv94/q8cHob+A42LBVk7FpFISfbRvHkb
         6VnyABWV8PKEljbelpcopvZZzvakS2hSsaHabCoK0etlEXyAWWz48WdNCagj40mqmyFT
         ouvn9Jm7Hcvm9nKhrurDqm0x/8+BfwgmZZTu53IUmmQ69A4x+QNnRcqeMp5JLq96x9iw
         CTNQ==
X-Gm-Message-State: AHQUAuZdPjJ+t2WXd1/tUr2+EcRjFjY5K0w4Q4hmi5NUd4kCzIGuyQlo
	GsSiFZTEhbxi4vxLXONfNyMaN39fzqzVsu07mDGmy+u1Naeg4YytzMsNXvaEE/uH6xv6sCFtkMc
	BqM6J+YHdf6MAPnJvp4SL021Cpw7TY6uVS7pCGdcGAfJo8vc9vk7fsSSDk1dPrmvjOa9nIBV1bb
	Uue13uOfdW8v/WkmclNgF8MK562j7KwSP9bvHmzPXMHIOd+w28+vahwj1hn5hsWF1dP1p6iujtV
	NrmakzWqG7Z1bUrASKjvg8/FeLqZ/s2suidB/hi/5e0k3MudcqeHZR2HUQe5+P09ke7xd1Y/LZy
	sq4NYAqqvogZC2wjQPq5+qsNHYUOQwMM9qRKgbMw3/yzC+JN3l7nXw6PcxaYA8/mt/Y1vE90XFF
	e
X-Received: by 2002:a63:c503:: with SMTP id f3mr11432667pgd.431.1549257703004;
        Sun, 03 Feb 2019 21:21:43 -0800 (PST)
X-Received: by 2002:a63:c503:: with SMTP id f3mr11432612pgd.431.1549257701624;
        Sun, 03 Feb 2019 21:21:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549257701; cv=none;
        d=google.com; s=arc-20160816;
        b=Q3n8XilajBWppLb5eonuBbZaIBaGisYh/LB1dCs9SR211+8peouzqe9NkL51vuJEVN
         qzkR7AhAL8JqLcNUbp1dLAXUI2oHNFddjz88CBlc5xVWJehLIoGFMuYjR4B5bQ6PLcFa
         gKEDxFDviKFc1QOHq71T2vWi86WL03aQcqUd9NLKaiVt+efC0BGOnF/T48PxcO7iK25u
         iEsm4fCrcT6hJQRcOuLc3Sxztt4wlhr8hSsO+S6T84a43SnanUJbkw1TChPhUMX/VYo/
         BFOtSssD+rJQxXiwbJWlJl1x8wgRoDh85Vz6s2GUvHUvr9JGJE/h8pmSvJBy0mqNVYqx
         50VA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=33aqc7VxCmQrf2zs2FpPkA7KtnfR/GRdMJWgpUgJpEM=;
        b=zwPrhJQYWDLlDUgUbn/HMobd++8llcCDhfSzAe7EnzXMkO5lRvJCSvTx03KZDj+tBN
         wnMCH2V2FTaPfOSGR/2UImYwksZvD9YbN7v9fC+OS3H7MtdpJTh4jfrv7rqdz/q4hy6J
         VPpTl+n9tNnWJyDhvx3/JUtqo3wOMj76sdMVDKpKwbNHxKwP1KIf5UJ2kYHuhjlQyvfp
         V353RQ4nuTM578FisXdvge9yfBHVLApSTQqU7KpIHJr2IoxQ63ycKoDIJAJQteZRHklt
         d9DDfDcePeKIgI1DfG+0e3fYHigUJv+/4/Om1V0xSCpPjA9TlRPoXg/YoxyQ2g+s4SBQ
         5NbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rhV20tUO;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f22sor23397443plr.54.2019.02.03.21.21.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Feb 2019 21:21:41 -0800 (PST)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rhV20tUO;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=33aqc7VxCmQrf2zs2FpPkA7KtnfR/GRdMJWgpUgJpEM=;
        b=rhV20tUOzRAwoBrB2k+KIEQ4rhsh+VgMEwfxA9wm3q1JaFEkxK3brr1BabNAKr8ZnP
         4U+3bdrembwJTNmxAHEfaHc/2lmmhLp/Sj+KZdBoekUcQWfevU+Q+vNfoK1Syxao76CV
         8aGFm68JPu2nZUt+PnKYY+rxiACW/6tGd2JKhlH/Lr2R4Ne7LyOK5GmMyo3ATkg3wrX1
         P+eGzuLuGfNB77wK0ME5ZhIl1UdafkW2gwtu5+/2vNDFPpty5ts42sKx+J7kcl3ce4Te
         L8B2QF806Trwh8tLDMC2ZmGVeAzAEeZc82Ur0tQqcvJEGmo35IbRER1FYerhCGIXs7tp
         dGUA==
X-Google-Smtp-Source: ALg8bN73MwGWHnBooaP8AZJHWe/f3WIGVg3OcOtYA/m0+LniOBT9DMbGeIXgnjeEXpiVB+20hyZyuQ==
X-Received: by 2002:a17:902:7614:: with SMTP id k20mr50903027pll.285.1549257701233;
        Sun, 03 Feb 2019 21:21:41 -0800 (PST)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id m9sm33428844pgd.32.2019.02.03.21.21.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Feb 2019 21:21:40 -0800 (PST)
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
Subject: [PATCH 1/6] mm: introduce put_user_page*(), placeholder versions
Date: Sun,  3 Feb 2019 21:21:30 -0800
Message-Id: <20190204052135.25784-2-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190204052135.25784-1-jhubbard@nvidia.com>
References: <20190204052135.25784-1-jhubbard@nvidia.com>
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

