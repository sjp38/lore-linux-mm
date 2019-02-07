Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9D2CC282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 14:36:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A40021908
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 14:36:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="PTv9EPT2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A40021908
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC0518E0035; Thu,  7 Feb 2019 09:36:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6F5A8E0002; Thu,  7 Feb 2019 09:36:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C84D28E0035; Thu,  7 Feb 2019 09:36:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 733538E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 09:36:50 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id w16so16555wrk.10
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 06:36:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=USWTqNNaTFMecCWSHWRIq82FHnD40j+lsfqrz/0WGpY=;
        b=cZDCogwD/ltGqCVt3U3JdYOIs5376qpktd/bb0ljReSFJr6yIlJ9F1X3U8jjLpQ1iX
         xhfGSt9K1+JJDcEK8Ybno0i8GB3VORJ3296jobCjnTAMfI/kWgg0p9xJH8yfNi4yXHXu
         oJV4xAEhVmt9jrB0dPOA2nXp6hahmtiMKGwLbxJYx5Sjf9AwDYjiFW0mDqnEaUwnrZwC
         tpVbs5vtbWQjSPgVDr3js+JfXQ/HIm5KZ8OJCbjzR0D/CEfroVolNHnYTDh0G+5LukwT
         PjmfkP9lDbwl4CNWlFf6FJgb2q9zZpA7rBRuGESXjC5saLj94X0cx0a4Ob2qcamU3Ya1
         WPmg==
X-Gm-Message-State: AHQUAubYChuMLr1fXfYaiPuG8ODE035Vp/wfaf1wFCzI017yzhWeCRwj
	1/OteB/lPvysdbH9/tLBk5CRG9s6P5f+uqq0d1WA9a7KX1mbJYhYAXuEJ6fJ6qEhnkPszyek4uA
	eAE/NMnO3IUxgebJJx3ImgPFa49PjbJ+jjC+xhdQoQbQXzddtkR+jODfl0MrL9V62sw0f4+5Y+/
	NJRbwZY67IBbrQJFzFTnywiw3M4Wnd9YWutvTYYPh6MRbltJO7OttAzOkLeWtUMIokesGR9RjLg
	IxBJxm3toiewYDjJ7xfNLt9QdFM+H7sBr7XYM5JtGzOeYJVEp2aPBw8r1B6eMnjF907W78fbd5l
	bqYqhkWVKovghIr77zIoFcaXaluAeF5yF09ylpuutBP/SM9djD0n+3rGQOXH6bXrFHGnJziunm4
	e
X-Received: by 2002:a1c:4c0c:: with SMTP id z12mr7323778wmf.17.1549550209940;
        Thu, 07 Feb 2019 06:36:49 -0800 (PST)
X-Received: by 2002:a1c:4c0c:: with SMTP id z12mr7323709wmf.17.1549550208757;
        Thu, 07 Feb 2019 06:36:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549550208; cv=none;
        d=google.com; s=arc-20160816;
        b=zIJwYgUZODUb2L8QiV1nyVicTkmtanwQtFxg8TtRWn67aa8nxXZLXHZMlJciFL3RJV
         LdiQTKDU0FvizMjFGjIXzY5wreX8qfi/ZuEi4ELOzyGDQuyLzEN7+Q8Ni/MxwkmNatZG
         cr8XzOxBBllzcqXUu5U8eiwpnnyTJWQKWBIqPidW6Q/GFPvlsxrbO08DrGRlIgq3x/O6
         Gk391v8caJt6xvO42kvSboQIuOjGHW+tzo9zqaShDF8BgFrqSGehMn/aOKu+CGUzv0I7
         AKusR5JS6TIZemN5Y6c2VeuxLE6+xkdn5X30BMl/oEZezJWvzbSrMkl8j7rGnM32qXqy
         CKGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=USWTqNNaTFMecCWSHWRIq82FHnD40j+lsfqrz/0WGpY=;
        b=HusM1Oe4YJzPuE+PItQLBfDFVjdLAmSRqMbYb/3Qeq35XnhJm2jkGlhWu2ifMpbfMy
         lb3IkCLhHSSTIpY3iWS6lJrA5t8HDKCxTX85p/e3mM/5JjBGkMYOw/7HHEKgVoegPTT7
         YifjYGdlfEqrscoaJVpb/1NAn+lXTToAHNvhHt9TMdbXAGavYwFrJ8aMxIcWQAaxmP5H
         cWByYwSrPvfbKkXjFta62AAWUanJivHCAHggImWXQUfLPhOMFnMrBknRt1mNz64ou7XV
         J6RlDxWIi2MgbY/DKadMWvGs+E6u74FwgYgDE7sLiUXFsfK9X463DvnC2Uoce/ymKR29
         tlxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=PTv9EPT2;
       spf=pass (google.com: domain of ilias.apalodimas@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ilias.apalodimas@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f20sor13449793wml.10.2019.02.07.06.36.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 06:36:48 -0800 (PST)
Received-SPF: pass (google.com: domain of ilias.apalodimas@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=PTv9EPT2;
       spf=pass (google.com: domain of ilias.apalodimas@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ilias.apalodimas@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=USWTqNNaTFMecCWSHWRIq82FHnD40j+lsfqrz/0WGpY=;
        b=PTv9EPT29LlNcqMeVoydVc4XWa4we0Cg3MnxIMD40V7yonzExbA+u//uju3oeCi8Z8
         45CeJ5A60zb0Bse46U6ZxxptxcB7HhiTZ+2KCUXGf/JkM7pKSYE9WRNwVXbMs7Nu1qrj
         3ZJLW0Ld28J8UTxB30xcSMpmSb+IWc86i+oqE3bcGupfRIhwIQUbT+HBe7q8wGTQwHfS
         3IxLxCC8gOArTX6Barc3KQ8RyMhJDXjj4xF5UXM9L3aH2Zxw2bxcLOMc8l9K0FQFvNQj
         2eTSHEobwlmj7OjpvywKsTvDEQMw4pi3vjBSi2XHwYf1MIkDFZpEUia5KDngtNyvbB9u
         s/gQ==
X-Google-Smtp-Source: AHgI3IZRV5RwJJ2iBBNsoHkX9/iDu98wVrKhmD0xdJK+GLCfP53ndLN01SJ2MoI7TxcwvMvKXxdSbQ==
X-Received: by 2002:a1c:26c1:: with SMTP id m184mr7370762wmm.25.1549550208059;
        Thu, 07 Feb 2019 06:36:48 -0800 (PST)
Received: from apalos.lan (ppp-94-65-225-153.home.otenet.gr. [94.65.225.153])
        by smtp.gmail.com with ESMTPSA id m6sm17332938wrv.24.2019.02.07.06.36.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 07 Feb 2019 06:36:47 -0800 (PST)
From: Ilias Apalodimas <ilias.apalodimas@linaro.org>
To: brouer@redhat.com,
	tariqt@mellanox.com,
	toke@redhat.com
Cc: davem@davemloft.net,
	netdev@vger.kernel.org,
	mgorman@techsingularity.net,
	linux-mm@kvack.org,
	Ilias Apalodimas <ilias.apalodimas@linaro.org>
Subject: [RFC, PATCH] net: page_pool: Don't use page->private to store dma_addr_t
Date: Thu,  7 Feb 2019 16:36:36 +0200
Message-Id: <1549550196-25581-1-git-send-email-ilias.apalodimas@linaro.org>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As pointed out in
https://www.mail-archive.com/netdev@vger.kernel.org/msg257926.html
the current page_pool implementation stores dma_addr_t in page->private.
This won't work on 32-bit platforms with 64-bit DMA addresses since the
page->private is an unsigned long and the dma_addr_t a u64.

Since no driver is yet using the DMA mapping capabilities of the API let's
try and fix this by shadowing struct_page and use 'struct list_head lru'
to store and retrieve DMA addresses from network drivers.
As long as the addresses returned from dma_map_page() are aligned the
first bit, used by the compound pages code should not be set.

Signed-off-by: Ilias Apalodimas <ilias.apalodimas@linaro.org>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/net/page_pool.h | 55 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/core/page_pool.c    | 18 ++++++++++++----
 2 files changed, 69 insertions(+), 4 deletions(-)

diff --git a/include/net/page_pool.h b/include/net/page_pool.h
index 694d055..618f2e5 100644
--- a/include/net/page_pool.h
+++ b/include/net/page_pool.h
@@ -98,6 +98,52 @@ struct page_pool {
 	struct ptr_ring ring;
 };
 
+/* Until we can update struct-page, have a shadow struct-page, that
+ * include our use-case
+ * Used to store retrieve dma addresses from network drivers.
+ * Never access this directly, use helper functions provided
+ * page_pool_get_dma_addr()
+ */
+struct page_shadow {
+	unsigned long flags;		/* Atomic flags, some possibly
+					 * updated asynchronously
+					 */
+	/*
+	 * Five words (20/40 bytes) are available in this union.
+	 * WARNING: bit 0 of the first word is used for PageTail(). That
+	 * means the other users of this union MUST NOT use the bit to
+	 * avoid collision and false-positive PageTail().
+	 */
+	union {
+		struct {	/* Page cache and anonymous pages */
+			/**
+			 * @lru: Pageout list, eg. active_list protected by
+			 * zone_lru_lock.  Sometimes used as a generic list
+			 * by the page owner.
+			 */
+			struct list_head lru;
+			/* See page-flags.h for PAGE_MAPPING_FLAGS */
+			struct address_space *mapping;
+			pgoff_t index;		/* Our offset within mapping. */
+			/**
+			 * @private: Mapping-private opaque data.
+			 * Usually used for buffer_heads if PagePrivate.
+			 * Used for swp_entry_t if PageSwapCache.
+			 * Indicates order in the buddy system if PageBuddy.
+			 */
+			unsigned long private;
+		};
+		struct {	/* page_pool used by netstack */
+			/**
+			 * @dma_addr: Page_pool need to store DMA-addr, and
+			 * cannot use @private, as DMA-mappings can be 64bit
+			 * even on 32-bit Architectures.
+			 */
+			dma_addr_t dma_addr; /* Shares area with @lru */
+		};
+	};
+};
+
 struct page *page_pool_alloc_pages(struct page_pool *pool, gfp_t gfp);
 
 static inline struct page *page_pool_dev_alloc_pages(struct page_pool *pool)
@@ -141,4 +187,13 @@ static inline bool is_page_pool_compiled_in(void)
 #endif
 }
 
+static inline dma_addr_t page_pool_get_dma_addr(struct page *page)
+{
+	struct page_shadow *_page;
+
+	_page = (struct page_shadow *)page;
+
+	return _page->dma_addr;
+}
+
 #endif /* _NET_PAGE_POOL_H */
diff --git a/net/core/page_pool.c b/net/core/page_pool.c
index 43a932c..1a956a6 100644
--- a/net/core/page_pool.c
+++ b/net/core/page_pool.c
@@ -111,6 +111,7 @@ noinline
 static struct page *__page_pool_alloc_pages_slow(struct page_pool *pool,
 						 gfp_t _gfp)
 {
+	struct page_shadow *_page;
 	struct page *page;
 	gfp_t gfp = _gfp;
 	dma_addr_t dma;
@@ -136,7 +137,7 @@ static struct page *__page_pool_alloc_pages_slow(struct page_pool *pool,
 	if (!(pool->p.flags & PP_FLAG_DMA_MAP))
 		goto skip_dma_map;
 
-	/* Setup DMA mapping: use page->private for DMA-addr
+	/* Setup DMA mapping: use struct-page area for storing DMA-addr
 	 * This mapping is kept for lifetime of page, until leaving pool.
 	 */
 	dma = dma_map_page(pool->p.dev, page, 0,
@@ -146,7 +147,8 @@ static struct page *__page_pool_alloc_pages_slow(struct page_pool *pool,
 		put_page(page);
 		return NULL;
 	}
-	set_page_private(page, dma); /* page->private = dma; */
+	_page = (struct page_shadow *)page;
+	_page->dma_addr = dma;
 
 skip_dma_map:
 	/* When page just alloc'ed is should/must have refcnt 1. */
@@ -175,13 +177,21 @@ EXPORT_SYMBOL(page_pool_alloc_pages);
 static void __page_pool_clean_page(struct page_pool *pool,
 				   struct page *page)
 {
+	struct page_shadow *_page = (struct page_shadow *)page;
+	dma_addr_t dma;
+
 	if (!(pool->p.flags & PP_FLAG_DMA_MAP))
 		return;
 
+	dma = _page->dma_addr;
+
 	/* DMA unmap */
-	dma_unmap_page(pool->p.dev, page_private(page),
+	dma_unmap_page(pool->p.dev, dma,
 		       PAGE_SIZE << pool->p.order, pool->p.dma_dir);
-	set_page_private(page, 0);
+	_page->dma_addr = 0;
+	/* 1. Make sure we don't need to list-init page->lru.
+	 * 2. What does it mean: bit 0 of LRU first word is used for PageTail()
+	 */
 }
 
 /* Return a page to the page allocator, cleaning up our state */
-- 
2.7.4

