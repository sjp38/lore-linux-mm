Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67217C10F0C
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 23:55:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A35A20684
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 23:55:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="B1LnaV/j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A35A20684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D47E8E0004; Wed,  6 Mar 2019 18:55:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 887158E0002; Wed,  6 Mar 2019 18:55:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 703298E0004; Wed,  6 Mar 2019 18:55:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 263948E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 18:55:02 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id a72so15411416pfj.19
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 15:55:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jfGGLSgiEqRRIhNtKMeSWmFJ5Q1D+P8BXUhWWj/EOPk=;
        b=ltJ4oW+nm7UnqrznZ4Qnd2uJRsPVXdHHhnU8I9lH4MHARaEyxtRw2PggnAu+PX26Zk
         LBRlajmN2ufeV0nKCiqs3HjauXAnvGgEpTp+WebbrXhazkAPJYTMiW6tH6rmxLRSqVqm
         f4e6K7vZJwDzAgQq/6Opcl92Dk9a5hn7Ei156hni75II4ISnn7hMam8yoxVMigwPu/3R
         hrcOo/WWW8b7k2XHM0FWVVIpH6PHFYgHpb8aVtLCp8cM744GveZVV10pkbLRtmdZgI5u
         XbFwNCa1LI4ZcARu/ecsIQq3+0yCVTlwgllNgOl6SshMu6U8boIGPI70lgPUCPY4Z/aU
         NhFg==
X-Gm-Message-State: APjAAAXu4kQJ30FXUJcSlhc10F9lBGCyNPE9+LPVFqm5yTBHSg7kKR0Z
	MjDtYLvQUwurr+BK8qrGh/puB1ZXhNcRiqCqYoRVVghgER6zyM5kvHUweNHbNSR6UVdEwiWu6kc
	oyldaHFjGruYtWUMHsi4I7z6WR6HXJEADS7IU+I84JeoxFH4jPLHr7Jh+lpEpvL1QjkzGU7P7yH
	AMS/ZTE/j5P/Nh5RpIh1Qq8RkJGR4gq/xgjHG+pMvFhBuk9uY3ioibzxisS0KFs34m4S5RAE9CD
	ApgZ9WKUfYxK2qEoNrRAe0FlckJdsIeZvqDtVD3LwdT20vtL3Y+guw5CD1bFOPlpQyRgi6xWmBL
	uYACwCi2j2o8/zQtbhJsk0staEiRMFyrMqX4x0KzqTlwS+JcFpjo4SlxlwQRZL2c6c91sdf0+1g
	x
X-Received: by 2002:a63:fe58:: with SMTP id x24mr8737351pgj.255.1551916501786;
        Wed, 06 Mar 2019 15:55:01 -0800 (PST)
X-Received: by 2002:a63:fe58:: with SMTP id x24mr8737306pgj.255.1551916500878;
        Wed, 06 Mar 2019 15:55:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551916500; cv=none;
        d=google.com; s=arc-20160816;
        b=Y7MLDBNM9RJrlxYQci/0MjmuYhYMCkCAjBOrDsAvB4J1RfpPIYm4HbjMx07Vnie5og
         IeEFyfS8lve9FbFOv9P1N1T3mu3XvulPa7YyvyCobpHFP7PJyTmuUnUS/mpdcUgFopSx
         XgeO617BeHG8rjnaR/0iTZVBzXWrXFSxCgAXaFVrsywoEGmKhqJMsqmze4a27pqYDCtQ
         t8XOQyzjxP4Iqmyrgl6Dc+skagEuQb3eVkEPCpeUC+38fCppiwONFOK594QFUQ9UQDxe
         1iBiFjI+G17W+Mt/p3wd0nIqmc/8XYuIsoFIl0Zo//rqQHm3t5ktTBDPDLHCnJy3ONMy
         YxGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=jfGGLSgiEqRRIhNtKMeSWmFJ5Q1D+P8BXUhWWj/EOPk=;
        b=csYZGkNVHynb5VRh9FfCZZwWoDbidkoKt9BmRAng4fYR9WuqMapjOeN/vYqm27607M
         NY7ArB5oDTrkV2nhbV4BGK4Z6OOXA9TO0HlNl3U2twX/mvCFBpY0j+3/CTFFSEn2tj/T
         jIx4ms6RmezATomozpgbhkQTH2kX0FWmdap5Iqv5Cr9M6lHCod9LIcMErUbQTcnqsHhh
         hLsTmY64PBiooAbSNNhNxpLA1CTYl6vo9+7ErbDc8rQNB60h8+X/1N9D7jXxW/OzIldM
         l9aJpZz81lPIj2t8l5PjxOjojSOjcb/DnhbgtkvT9oib6c3E+Nr7enW37VVMU9u9u28K
         1XfA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="B1LnaV/j";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w187sor5416659pfb.17.2019.03.06.15.55.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 15:55:00 -0800 (PST)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="B1LnaV/j";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=jfGGLSgiEqRRIhNtKMeSWmFJ5Q1D+P8BXUhWWj/EOPk=;
        b=B1LnaV/jVndR+cAZ/RkR7o+SL9tikbmGZs7n6kvQdS3FMc/PL0+j5F2uqolXJW111r
         8ziP7E/ZohP4xEj6t58zjuzuXF0e1mr86Z+LzzeH3orTx2RFrWSEC8wDlgpfU2QqXU4n
         TsREvawMv+xct8XZGjOgZfYSaeCDm0E+72CEjfSboF9Pfp0882mQAJuCEiMzMIwhIik0
         sy2MdoInyfLsQtSZ6zplXwAu6P/xODtus3K1XUV0LaZTyQOSu77BqXo2rKREvfx75Znw
         e6UzzO1fntox7OWS/Oxava/7JydIsP/ox80GIZSz8kFdWEBtGan6Fdlst45v+ComZKpY
         dFdw==
X-Google-Smtp-Source: APXvYqycahrYGsQ90tSFc0UZqqTXqqUCsCJw+ivh+pMgtm7yYBnb4sG9rVqVh8m3n/q/LbKhqXu5YQ==
X-Received: by 2002:a62:ed08:: with SMTP id u8mr9853358pfh.200.1551916500516;
        Wed, 06 Mar 2019 15:55:00 -0800 (PST)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id m21sm4955272pfa.14.2019.03.06.15.54.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 15:54:59 -0800 (PST)
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
Subject: [PATCH v3 1/1] mm: introduce put_user_page*(), placeholder versions
Date: Wed,  6 Mar 2019 15:54:55 -0800
Message-Id: <20190306235455.26348-2-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190306235455.26348-1-jhubbard@nvidia.com>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
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
index 4d7d37eb3c40..a6b4f693f46d 100644
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
2.21.0

