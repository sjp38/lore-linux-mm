Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12B67C10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:38:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABEB220835
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:38:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rFGzCV6f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABEB220835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 561216B0007; Wed, 17 Apr 2019 04:38:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50D076B000A; Wed, 17 Apr 2019 04:38:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3890D6B000D; Wed, 17 Apr 2019 04:38:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id BD3606B0007
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 04:38:31 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id d17so2496449lfb.13
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:38:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Sd3LnrKhw2tgRz9UNxG9ueVkl/OGNG8X97V5bhmMYJo=;
        b=Mx5KdEfBVrp7gFYupuCGlh6D31P0YvjYds2Guo5tXEJ1TFRotcGYD76D3FelVWzCzJ
         HrAzEnCZast2ZjgGf9LU5UF8ypqE0+EYVsflZc4E3d/XoBgUMxfv2OfEqURH+7QGjAMt
         9ShCvf2bl8GM1zA70wOYe9Z/XicOegfhP65kF0nXMGgZ1Tj78mHDGAaOiJEktv8lhFx7
         afZqHl6xwdgtNDV4YLxOJiJgYJzlWnbCzsvEy4YVgKYcqBy1/+QRU8LkWjBv7s6WLoNs
         jZkWVjKd87dSjA/UEYV54/dpRXXmOGPzJd/u0GRvvekK5kkxDd5eoQ7ZMQ+KMxvrW08o
         JYmA==
X-Gm-Message-State: APjAAAUw9uj+bUWzRYBll9gZNyBReFxleuyQy7cGm1GsBLT1iJ1rgQZf
	LHNfmhxq0ZUkjgneODhTRBXWclraC0bCduaRE2CVy3xPr/geoUIrbw1KLAIGgfCg9Fe++iKBnLf
	4IvvecovCT5EiieAEWHX5UXrbrToGmrAcwY4rtEZRKMn9mo/JnxhPEJM1Qd2Do1UBkw==
X-Received: by 2002:a2e:7d19:: with SMTP id y25mr24778086ljc.126.1555490311069;
        Wed, 17 Apr 2019 01:38:31 -0700 (PDT)
X-Received: by 2002:a2e:7d19:: with SMTP id y25mr24777995ljc.126.1555490309227;
        Wed, 17 Apr 2019 01:38:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555490309; cv=none;
        d=google.com; s=arc-20160816;
        b=OT8IO/pG7SDGawQbIwnDQf9xCwGRui+2wFmhojN/nUdkKboSdC8cm5qK0O9MJB78H1
         N/3gT6nZaQtYfcRrGExkVFMA8nJ3I4RtACq71Nw6rmo/fQWr/bK62mImud/t02VgLtks
         EW/Olcvj316UDvpK4pqrmEBLx8yqColmjtj05PZo/+HcM6AGPeCN2+iimrzlatXoV8Hu
         TjHeqRUak71qsfihtt2cBrhatRWyTAEFDzy5s40dUEEKpsvcJv4BdnNbgCOUZF8YBSUS
         w1rtvcv2707A6UTrje5swPZplYOmSlX6raAy/iNevAZ0Drv1a/i9YibYT9QOgoLEwqlM
         2QQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Sd3LnrKhw2tgRz9UNxG9ueVkl/OGNG8X97V5bhmMYJo=;
        b=LsdjgvpSkI3RL6TGir53EkrSKc5Xm5mlowKUafLorrEQ/P1z+Dl1mKsPG087i13q23
         4QvH2jO6FmDT4XzTCYzyS7O1gFmmKJv12a7GjAw4hyLr4ahwDGJcUaeeMHrb47dUBESH
         an6NhyNzSj5P25v9pkwAZzOes6nBmzSNwqOIbI1GWZlE0rpp5d7C5NEiVLn6fMJKt8qq
         3TvCPO+eCwtDDhzIEdzukXvfAsjNmwV86EQ+GwtvFQrLJKYyR3WfWB4OuRt3J25jmap9
         PPyYuu9DSJtm+56WWSiP0/2Ak0gxW0F6eqtUBPpfjf0MixbTUsSAHfQWvNUuUaqLtC2+
         oLbg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rFGzCV6f;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p13sor34197721ljj.25.2019.04.17.01.38.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 01:38:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rFGzCV6f;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Sd3LnrKhw2tgRz9UNxG9ueVkl/OGNG8X97V5bhmMYJo=;
        b=rFGzCV6fX6StJ5G0K5fC7EVFFfqaK1iDfsJPnIQ/7XkvmUDWe/a9Kb9Z9b2A8frmHm
         oqz9FpY0ZyPWyRTInMckiv6mrmYCgLVMRpf6qSYQwEZkhnkj0zt/90Afqtz7cGKzlAFp
         j4nbDNzAU5vsLKq6LkhFrALAsSu3o5+NipaRXx3jXYPbCSQ55TH2Ih5Wm0jGnUwDA0tF
         +I0LfLR8Xr6bAz7TGBiJx+Uo34S+OJ5z0L9u27l965felx/GMAabda5uLYKA08DUh42Q
         QI7wkN/WmynijmlAOf/zzY99WFgq/XnKS8o1sH8+uy9KAJ3Xx/peXr5cryIBef0z25Au
         185w==
X-Google-Smtp-Source: APXvYqzDOdmW2Tjh3gHF4VHAQw0qCWki0/5SCGLAS0g65kd+ISDVNM897NcFG+QvgPceqJZODVjA6g==
X-Received: by 2002:a2e:3010:: with SMTP id w16mr46578193ljw.62.1555490308302;
        Wed, 17 Apr 2019 01:38:28 -0700 (PDT)
Received: from seldlx21914.corpusers.net ([37.139.156.40])
        by smtp.gmail.com with ESMTPSA id r2sm10796523ljd.16.2019.04.17.01.38.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 01:38:27 -0700 (PDT)
Date: Wed, 17 Apr 2019 10:38:26 +0200
From: Vitaly Wool <vitalywool@gmail.com>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton
 <akpm@linux-foundation.org>, Oleksiy.Avramchenko@sony.com, Bartlomiej
 Zolnierkiewicz <b.zolnierkie@samsung.com>, Krzysztof Kozlowski
 <k.kozlowski@samsung.com>
Subject: [PATCHv2 3/4] z3fold: add structure for buddy handles
Message-Id: <20190417103826.484eaf18c1294d682769880f@gmail.com>
In-Reply-To: <20190417103510.36b055f3314e0e32b916b30a@gmail.com>
References: <20190417103510.36b055f3314e0e32b916b30a@gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.30; x86_64-unknown-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For z3fold to be able to move its pages per request of the memory
subsystem, it should not use direct object addresses in handles.
Instead, it will create abstract handles (3 per page) which will
contain pointers to z3fold objects. Thus, it will be possible to
change these pointers when z3fold page is moved.

Signed-off-by: Vitaly Wool <vitaly.vul@sony.com>
---
 mm/z3fold.c | 185 ++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 145 insertions(+), 40 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 29a4f1249bef..bebc10083f1c 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -34,6 +34,29 @@
 #include <linux/spinlock.h>
 #include <linux/zpool.h>
 
+/*
+ * NCHUNKS_ORDER determines the internal allocation granularity, effectively
+ * adjusting internal fragmentation.  It also determines the number of
+ * freelists maintained in each pool. NCHUNKS_ORDER of 6 means that the
+ * allocation granularity will be in chunks of size PAGE_SIZE/64. Some chunks
+ * in the beginning of an allocated page are occupied by z3fold header, so
+ * NCHUNKS will be calculated to 63 (or 62 in case CONFIG_DEBUG_SPINLOCK=y),
+ * which shows the max number of free chunks in z3fold page, also there will
+ * be 63, or 62, respectively, freelists per pool.
+ */
+#define NCHUNKS_ORDER	6
+
+#define CHUNK_SHIFT	(PAGE_SHIFT - NCHUNKS_ORDER)
+#define CHUNK_SIZE	(1 << CHUNK_SHIFT)
+#define ZHDR_SIZE_ALIGNED round_up(sizeof(struct z3fold_header), CHUNK_SIZE)
+#define ZHDR_CHUNKS	(ZHDR_SIZE_ALIGNED >> CHUNK_SHIFT)
+#define TOTAL_CHUNKS	(PAGE_SIZE >> CHUNK_SHIFT)
+#define NCHUNKS		((PAGE_SIZE - ZHDR_SIZE_ALIGNED) >> CHUNK_SHIFT)
+
+#define BUDDY_MASK	(0x3)
+#define BUDDY_SHIFT	2
+#define SLOTS_ALIGN	(0x40)
+
 /*****************
  * Structures
 *****************/
@@ -47,9 +70,19 @@ enum buddy {
 	FIRST,
 	MIDDLE,
 	LAST,
-	BUDDIES_MAX
+	BUDDIES_MAX = LAST
 };
 
+struct z3fold_buddy_slots {
+	/*
+	 * we are using BUDDY_MASK in handle_to_buddy etc. so there should
+	 * be enough slots to hold all possible variants
+	 */
+	unsigned long slot[BUDDY_MASK + 1];
+	unsigned long pool; /* back link + flags */
+};
+#define HANDLE_FLAG_MASK	(0x03)
+
 /*
  * struct z3fold_header - z3fold page metadata occupying first chunks of each
  *			z3fold page, except for HEADLESS pages
@@ -58,7 +91,7 @@ enum buddy {
  * @page_lock:		per-page lock
  * @refcount:		reference count for the z3fold page
  * @work:		work_struct for page layout optimization
- * @pool:		pointer to the pool which this page belongs to
+ * @slots:		pointer to the structure holding buddy slots
  * @cpu:		CPU which this page "belongs" to
  * @first_chunks:	the size of the first buddy in chunks, 0 if free
  * @middle_chunks:	the size of the middle buddy in chunks, 0 if free
@@ -70,7 +103,7 @@ struct z3fold_header {
 	spinlock_t page_lock;
 	struct kref refcount;
 	struct work_struct work;
-	struct z3fold_pool *pool;
+	struct z3fold_buddy_slots *slots;
 	short cpu;
 	unsigned short first_chunks;
 	unsigned short middle_chunks;
@@ -79,28 +112,6 @@ struct z3fold_header {
 	unsigned short first_num:2;
 };
 
-/*
- * NCHUNKS_ORDER determines the internal allocation granularity, effectively
- * adjusting internal fragmentation.  It also determines the number of
- * freelists maintained in each pool. NCHUNKS_ORDER of 6 means that the
- * allocation granularity will be in chunks of size PAGE_SIZE/64. Some chunks
- * in the beginning of an allocated page are occupied by z3fold header, so
- * NCHUNKS will be calculated to 63 (or 62 in case CONFIG_DEBUG_SPINLOCK=y),
- * which shows the max number of free chunks in z3fold page, also there will
- * be 63, or 62, respectively, freelists per pool.
- */
-#define NCHUNKS_ORDER	6
-
-#define CHUNK_SHIFT	(PAGE_SHIFT - NCHUNKS_ORDER)
-#define CHUNK_SIZE	(1 << CHUNK_SHIFT)
-#define ZHDR_SIZE_ALIGNED round_up(sizeof(struct z3fold_header), CHUNK_SIZE)
-#define ZHDR_CHUNKS	(ZHDR_SIZE_ALIGNED >> CHUNK_SHIFT)
-#define TOTAL_CHUNKS	(PAGE_SIZE >> CHUNK_SHIFT)
-#define NCHUNKS		((PAGE_SIZE - ZHDR_SIZE_ALIGNED) >> CHUNK_SHIFT)
-
-#define BUDDY_MASK	(0x3)
-#define BUDDY_SHIFT	2
-
 /**
  * struct z3fold_pool - stores metadata for each z3fold pool
  * @name:	pool name
@@ -113,6 +124,7 @@ struct z3fold_header {
  *		added buddy.
  * @stale:	list of pages marked for freeing
  * @pages_nr:	number of z3fold pages in the pool.
+ * @c_handle:	cache for z3fold_buddy_slots allocation
  * @ops:	pointer to a structure of user defined operations specified at
  *		pool creation time.
  * @compact_wq:	workqueue for page layout background optimization
@@ -130,6 +142,7 @@ struct z3fold_pool {
 	struct list_head lru;
 	struct list_head stale;
 	atomic64_t pages_nr;
+	struct kmem_cache *c_handle;
 	const struct z3fold_ops *ops;
 	struct zpool *zpool;
 	const struct zpool_ops *zpool_ops;
@@ -164,11 +177,65 @@ static int size_to_chunks(size_t size)
 
 static void compact_page_work(struct work_struct *w);
 
+static inline struct z3fold_buddy_slots *alloc_slots(struct z3fold_pool *pool)
+{
+	struct z3fold_buddy_slots *slots = kmem_cache_alloc(pool->c_handle,
+							GFP_KERNEL);
+
+	if (slots) {
+		memset(slots->slot, 0, sizeof(slots->slot));
+		slots->pool = (unsigned long)pool;
+	}
+
+	return slots;
+}
+
+static inline struct z3fold_pool *slots_to_pool(struct z3fold_buddy_slots *s)
+{
+	return (struct z3fold_pool *)(s->pool & ~HANDLE_FLAG_MASK);
+}
+
+static inline struct z3fold_buddy_slots *handle_to_slots(unsigned long handle)
+{
+	return (struct z3fold_buddy_slots *)(handle & ~(SLOTS_ALIGN - 1));
+}
+
+static inline void free_handle(unsigned long handle)
+{
+	struct z3fold_buddy_slots *slots;
+	int i;
+	bool is_free;
+
+	if (handle & (1 << PAGE_HEADLESS))
+		return;
+
+	WARN_ON(*(unsigned long *)handle == 0);
+	*(unsigned long *)handle = 0;
+	slots = handle_to_slots(handle);
+	is_free = true;
+	for (i = 0; i <= BUDDY_MASK; i++) {
+		if (slots->slot[i]) {
+			is_free = false;
+			break;
+		}
+	}
+
+	if (is_free) {
+		struct z3fold_pool *pool = slots_to_pool(slots);
+
+		kmem_cache_free(pool->c_handle, slots);
+	}
+}
+
 /* Initializes the z3fold header of a newly allocated z3fold page */
 static struct z3fold_header *init_z3fold_page(struct page *page,
 					struct z3fold_pool *pool)
 {
 	struct z3fold_header *zhdr = page_address(page);
+	struct z3fold_buddy_slots *slots = alloc_slots(pool);
+
+	if (!slots)
+		return NULL;
 
 	INIT_LIST_HEAD(&page->lru);
 	clear_bit(PAGE_HEADLESS, &page->private);
@@ -185,7 +252,7 @@ static struct z3fold_header *init_z3fold_page(struct page *page,
 	zhdr->first_num = 0;
 	zhdr->start_middle = 0;
 	zhdr->cpu = -1;
-	zhdr->pool = pool;
+	zhdr->slots = slots;
 	INIT_LIST_HEAD(&zhdr->buddy);
 	INIT_WORK(&zhdr->work, compact_page_work);
 	return zhdr;
@@ -215,33 +282,57 @@ static inline void z3fold_page_unlock(struct z3fold_header *zhdr)
 	spin_unlock(&zhdr->page_lock);
 }
 
+/* Helper function to build the index */
+static inline int __idx(struct z3fold_header *zhdr, enum buddy bud)
+{
+	return (bud + zhdr->first_num) & BUDDY_MASK;
+}
+
 /*
  * Encodes the handle of a particular buddy within a z3fold page
  * Pool lock should be held as this function accesses first_num
  */
 static unsigned long encode_handle(struct z3fold_header *zhdr, enum buddy bud)
 {
-	unsigned long handle;
+	struct z3fold_buddy_slots *slots;
+	unsigned long h = (unsigned long)zhdr;
+	int idx = 0;
 
-	handle = (unsigned long)zhdr;
-	if (bud != HEADLESS) {
-		handle |= (bud + zhdr->first_num) & BUDDY_MASK;
-		if (bud == LAST)
-			handle |= (zhdr->last_chunks << BUDDY_SHIFT);
-	}
-	return handle;
+	/*
+	 * For a headless page, its handle is its pointer with the extra
+	 * PAGE_HEADLESS bit set
+	 */
+	if (bud == HEADLESS)
+		return h | (1 << PAGE_HEADLESS);
+
+	/* otherwise, return pointer to encoded handle */
+	idx = __idx(zhdr, bud);
+	h += idx;
+	if (bud == LAST)
+		h |= (zhdr->last_chunks << BUDDY_SHIFT);
+
+	slots = zhdr->slots;
+	slots->slot[idx] = h;
+	return (unsigned long)&slots->slot[idx];
 }
 
 /* Returns the z3fold page where a given handle is stored */
-static struct z3fold_header *handle_to_z3fold_header(unsigned long handle)
+static inline struct z3fold_header *handle_to_z3fold_header(unsigned long handle)
 {
-	return (struct z3fold_header *)(handle & PAGE_MASK);
+	unsigned long addr = handle;
+
+	if (!(addr & (1 << PAGE_HEADLESS)))
+		addr = *(unsigned long *)handle;
+
+	return (struct z3fold_header *)(addr & PAGE_MASK);
 }
 
 /* only for LAST bud, returns zero otherwise */
 static unsigned short handle_to_chunks(unsigned long handle)
 {
-	return (handle & ~PAGE_MASK) >> BUDDY_SHIFT;
+	unsigned long addr = *(unsigned long *)handle;
+
+	return (addr & ~PAGE_MASK) >> BUDDY_SHIFT;
 }
 
 /*
@@ -251,13 +342,18 @@ static unsigned short handle_to_chunks(unsigned long handle)
  */
 static enum buddy handle_to_buddy(unsigned long handle)
 {
-	struct z3fold_header *zhdr = handle_to_z3fold_header(handle);
-	return (handle - zhdr->first_num) & BUDDY_MASK;
+	struct z3fold_header *zhdr;
+	unsigned long addr;
+
+	WARN_ON(handle & (1 << PAGE_HEADLESS));
+	addr = *(unsigned long *)handle;
+	zhdr = (struct z3fold_header *)(addr & PAGE_MASK);
+	return (addr - zhdr->first_num) & BUDDY_MASK;
 }
 
 static inline struct z3fold_pool *zhdr_to_pool(struct z3fold_header *zhdr)
 {
-	return zhdr->pool;
+	return slots_to_pool(zhdr->slots);
 }
 
 static void __release_z3fold_page(struct z3fold_header *zhdr, bool locked)
@@ -583,6 +679,11 @@ static struct z3fold_pool *z3fold_create_pool(const char *name, gfp_t gfp,
 	pool = kzalloc(sizeof(struct z3fold_pool), gfp);
 	if (!pool)
 		goto out;
+	pool->c_handle = kmem_cache_create("z3fold_handle",
+				sizeof(struct z3fold_buddy_slots),
+				SLOTS_ALIGN, 0, NULL);
+	if (!pool->c_handle)
+		goto out_c;
 	spin_lock_init(&pool->lock);
 	spin_lock_init(&pool->stale_lock);
 	pool->unbuddied = __alloc_percpu(sizeof(struct list_head)*NCHUNKS, 2);
@@ -613,6 +714,8 @@ static struct z3fold_pool *z3fold_create_pool(const char *name, gfp_t gfp,
 out_unbuddied:
 	free_percpu(pool->unbuddied);
 out_pool:
+	kmem_cache_destroy(pool->c_handle);
+out_c:
 	kfree(pool);
 out:
 	return NULL;
@@ -626,6 +729,7 @@ static struct z3fold_pool *z3fold_create_pool(const char *name, gfp_t gfp,
  */
 static void z3fold_destroy_pool(struct z3fold_pool *pool)
 {
+	kmem_cache_destroy(pool->c_handle);
 	destroy_workqueue(pool->release_wq);
 	destroy_workqueue(pool->compact_wq);
 	kfree(pool);
@@ -818,6 +922,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		return;
 	}
 
+	free_handle(handle);
 	if (kref_put(&zhdr->refcount, release_z3fold_page_locked_list)) {
 		atomic64_dec(&pool->pages_nr);
 		return;
-- 
2.17.1

