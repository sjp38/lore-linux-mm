Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45E3DC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:02:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF8AD21738
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:02:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="TExW+hfJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF8AD21738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F4BB6B000C; Wed, 27 Mar 2019 14:02:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A56F6B000D; Wed, 27 Mar 2019 14:02:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4215E6B000E; Wed, 27 Mar 2019 14:02:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 081756B000C
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:02:58 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h69so14611587pfd.21
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:02:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pX/BQf2uIHZuY8KubKrUfyDZt4BVqWUHA1EC7oGfgmk=;
        b=mkgCLdg2G/jnJf1W7K4DrEdYBLQGc1tLYoti1UCG1iATF7oj/ydaQ7bm0zp9RNadCU
         Wgm8hr5Br4tg0PZOhPlL0WrHqliqq/zu/NCjuY5bUYBQn6kdSAC9cXxNtVqy8O49o/Rn
         Ck1i09xGH4OxTq0XlqyfxIFFKMgLKH7ebcHoRFDkwmAMRGcgD/ClK2Oqoed1+Evkuxig
         53Ta9zFHjjDko4dg46OfxUhFo30DMhQtVlsCdBJVN4fBE9FPuy3Ili05hbZ0JschDAuy
         RYIJdmf+yjO03i+PlE9vG8G7NzONdmDZ8iKY7kPu/n7gUid/YsS04PjcFuyXjnbGXngC
         Y2YA==
X-Gm-Message-State: APjAAAW7iwK0jJHhOlm4AmUw6bKNvqcAceruWtGOnpQIMS6zYhVB6b74
	ApM78YPgmxORLCpHR/783/wA98Qel8sMK1WlrkxkDfv0VF2Dm3CjvNIREM8w6FQ9diNHQfT/ChB
	TfxltoQ81x+wqqxbZ/9CWZdfw8rHcfq6Y06TgeZu/psM3Vh/w2TaoFj66Fiz0AUGfmA==
X-Received: by 2002:a63:4343:: with SMTP id q64mr6128535pga.105.1553709777656;
        Wed, 27 Mar 2019 11:02:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0+pJW+TjI08+vLt8X3nocjbSd2lX3hQPg4CpeNg5jYFP1H5SM4KtPhG2Vni17UI3tjP1u
X-Received: by 2002:a63:4343:: with SMTP id q64mr6128451pga.105.1553709776703;
        Wed, 27 Mar 2019 11:02:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553709776; cv=none;
        d=google.com; s=arc-20160816;
        b=dWJsMMq8z1iVUE51bgrHO2Z/REcVdOmkcchs+z0pr22XoCaJdoc+mCit1R85ZBlVKp
         4b21Q2Ta60wOSg3efo5+c3aiwPUX8oRXqo17I6+6QYQ3eenqd+OAia6mBTeHjuwJba3K
         NK+nrma1AWop0rNe9IU+22RIcM20iLPgduPWNQfUifxt26FQMB3DSTBcsw28+x1UGczg
         7DsUTB+UVJglAk2y5ow3wzy3rJPsrn93ceRzyuqfEjSnmIad31P0g2QJymVA3D6bF+cc
         jH7Swj5F5rJzZjPdL0ScGR5MXwESqvJqGL6g9E3/Gt12BobWP9X9AwxLOCXwQkCvWRFu
         74sA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=pX/BQf2uIHZuY8KubKrUfyDZt4BVqWUHA1EC7oGfgmk=;
        b=yCehgKoDFEgCn7EzFi8BxlGQVfw619ynRL0gyqL0FgEdugHoEPPnXpUtilHJzUPSDA
         aYyttX2OO3xyZ0k4aTj4EhjpuzWyMts3Khhuvtyc0PTgRKiCb3ZmAqNkWagtImMtZn40
         qxOCTpdEOWASAHC1q+pEszAIoo9BfANnT7VstzsZDzmx8HLgJUmVKjR4I/zDdtmqadu4
         0JQCaL3uab1SML1TiKf1+D71zroCIJZBp9MYXQHnKjs+NE6BNclAkC8nU9bDd28AbIaV
         cyD6d+aVlaYCYw6bgQvh3w8ZgrOJyAFqT6Zwzd3rxT9vMANtf9avJibQg0ImRU7X2NL1
         sBAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=TExW+hfJ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l6si18242776pgq.305.2019.03.27.11.02.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:02:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=TExW+hfJ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B95F721734;
	Wed, 27 Mar 2019 18:02:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553709776;
	bh=KvMgGkbQ8nBX+yLa6kdzJY3DXcwYJfNpJoKtsPjEQnc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=TExW+hfJCmBz0EK4eFp0JgUEFaxWGZSRtDMpx9X7mqAf/VgBZLZYymMvHAp7Xg4ic
	 sI1zNWTLjjUn/e1hA7aWdnktQan0LazEI+NIpPMjhyBYDHVq7W090VN60hmB3MdCvX
	 UYFJGAoPOkoe36LXcmDD3+0FaTuur0lO/GA4OrWM=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Andi Kleen <ak@linux.intel.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Omar Sandoval <osandov@fb.com>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	Shaohua Li <shli@kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Tejun Heo <tj@kernel.org>,
	Will Deacon <will.deacon@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 033/262] mm, swap: bounds check swap_info array accesses to avoid NULL derefs
Date: Wed, 27 Mar 2019 13:58:08 -0400
Message-Id: <20190327180158.10245-33-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327180158.10245-1-sashal@kernel.org>
References: <20190327180158.10245-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Daniel Jordan <daniel.m.jordan@oracle.com>

[ Upstream commit c10d38cc8d3e43f946b6c2bf4602c86791587f30 ]

Dan Carpenter reports a potential NULL dereference in
get_swap_page_of_type:

  Smatch complains that the NULL checks on "si" aren't consistent.  This
  seems like a real bug because we have not ensured that the type is
  valid and so "si" can be NULL.

Add the missing check for NULL, taking care to use a read barrier to
ensure CPU1 observes CPU0's updates in the correct order:

     CPU0                           CPU1
     alloc_swap_info()              if (type >= nr_swapfiles)
       swap_info[type] = p              /* handle invalid entry */
       smp_wmb()                    smp_rmb()
       ++nr_swapfiles               p = swap_info[type]

Without smp_rmb, CPU1 might observe CPU0's write to nr_swapfiles before
CPU0's write to swap_info[type] and read NULL from swap_info[type].

Ying Huang noticed other places in swapfile.c don't order these reads
properly.  Introduce swap_type_to_swap_info to encourage correct usage.

Use READ_ONCE and WRITE_ONCE to follow the Linux Kernel Memory Model
(see tools/memory-model/Documentation/explanation.txt).

This ordering need not be enforced in places where swap_lock is held
(e.g.  si_swapinfo) because swap_lock serializes updates to nr_swapfiles
and the swap_info array.

Link: http://lkml.kernel.org/r/20190131024410.29859-1-daniel.m.jordan@oracle.com
Fixes: ec8acf20afb8 ("swap: add per-partition lock for swapfile")
Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Suggested-by: "Huang, Ying" <ying.huang@intel.com>
Reviewed-by: Andrea Parri <andrea.parri@amarulasolutions.com>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Omar Sandoval <osandov@fb.com>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Tejun Heo <tj@kernel.org>
Cc: Will Deacon <will.deacon@arm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/swapfile.c | 51 +++++++++++++++++++++++++++++----------------------
 1 file changed, 29 insertions(+), 22 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index dbac1d49469d..67f60e051814 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -98,6 +98,15 @@ static atomic_t proc_poll_event = ATOMIC_INIT(0);
 
 atomic_t nr_rotate_swap = ATOMIC_INIT(0);
 
+static struct swap_info_struct *swap_type_to_swap_info(int type)
+{
+	if (type >= READ_ONCE(nr_swapfiles))
+		return NULL;
+
+	smp_rmb();	/* Pairs with smp_wmb in alloc_swap_info. */
+	return READ_ONCE(swap_info[type]);
+}
+
 static inline unsigned char swap_count(unsigned char ent)
 {
 	return ent & ~SWAP_HAS_CACHE;	/* may include COUNT_CONTINUED flag */
@@ -1044,12 +1053,14 @@ int get_swap_pages(int n_goal, swp_entry_t swp_entries[], int entry_size)
 /* The only caller of this function is now suspend routine */
 swp_entry_t get_swap_page_of_type(int type)
 {
-	struct swap_info_struct *si;
+	struct swap_info_struct *si = swap_type_to_swap_info(type);
 	pgoff_t offset;
 
-	si = swap_info[type];
+	if (!si)
+		goto fail;
+
 	spin_lock(&si->lock);
-	if (si && (si->flags & SWP_WRITEOK)) {
+	if (si->flags & SWP_WRITEOK) {
 		atomic_long_dec(&nr_swap_pages);
 		/* This is called for allocating swap entry, not cache */
 		offset = scan_swap_map(si, 1);
@@ -1060,6 +1071,7 @@ swp_entry_t get_swap_page_of_type(int type)
 		atomic_long_inc(&nr_swap_pages);
 	}
 	spin_unlock(&si->lock);
+fail:
 	return (swp_entry_t) {0};
 }
 
@@ -1071,9 +1083,9 @@ static struct swap_info_struct *__swap_info_get(swp_entry_t entry)
 	if (!entry.val)
 		goto out;
 	type = swp_type(entry);
-	if (type >= nr_swapfiles)
+	p = swap_type_to_swap_info(type);
+	if (!p)
 		goto bad_nofile;
-	p = swap_info[type];
 	if (!(p->flags & SWP_USED))
 		goto bad_device;
 	offset = swp_offset(entry);
@@ -1697,10 +1709,9 @@ int swap_type_of(dev_t device, sector_t offset, struct block_device **bdev_p)
 sector_t swapdev_block(int type, pgoff_t offset)
 {
 	struct block_device *bdev;
+	struct swap_info_struct *si = swap_type_to_swap_info(type);
 
-	if ((unsigned int)type >= nr_swapfiles)
-		return 0;
-	if (!(swap_info[type]->flags & SWP_WRITEOK))
+	if (!si || !(si->flags & SWP_WRITEOK))
 		return 0;
 	return map_swap_entry(swp_entry(type, offset), &bdev);
 }
@@ -2258,7 +2269,7 @@ static sector_t map_swap_entry(swp_entry_t entry, struct block_device **bdev)
 	struct swap_extent *se;
 	pgoff_t offset;
 
-	sis = swap_info[swp_type(entry)];
+	sis = swp_swap_info(entry);
 	*bdev = sis->bdev;
 
 	offset = swp_offset(entry);
@@ -2700,9 +2711,7 @@ static void *swap_start(struct seq_file *swap, loff_t *pos)
 	if (!l)
 		return SEQ_START_TOKEN;
 
-	for (type = 0; type < nr_swapfiles; type++) {
-		smp_rmb();	/* read nr_swapfiles before swap_info[type] */
-		si = swap_info[type];
+	for (type = 0; (si = swap_type_to_swap_info(type)); type++) {
 		if (!(si->flags & SWP_USED) || !si->swap_map)
 			continue;
 		if (!--l)
@@ -2722,9 +2731,7 @@ static void *swap_next(struct seq_file *swap, void *v, loff_t *pos)
 	else
 		type = si->type + 1;
 
-	for (; type < nr_swapfiles; type++) {
-		smp_rmb();	/* read nr_swapfiles before swap_info[type] */
-		si = swap_info[type];
+	for (; (si = swap_type_to_swap_info(type)); type++) {
 		if (!(si->flags & SWP_USED) || !si->swap_map)
 			continue;
 		++*pos;
@@ -2831,14 +2838,14 @@ static struct swap_info_struct *alloc_swap_info(void)
 	}
 	if (type >= nr_swapfiles) {
 		p->type = type;
-		swap_info[type] = p;
+		WRITE_ONCE(swap_info[type], p);
 		/*
 		 * Write swap_info[type] before nr_swapfiles, in case a
 		 * racing procfs swap_start() or swap_next() is reading them.
 		 * (We never shrink nr_swapfiles, we never free this entry.)
 		 */
 		smp_wmb();
-		nr_swapfiles++;
+		WRITE_ONCE(nr_swapfiles, nr_swapfiles + 1);
 	} else {
 		kvfree(p);
 		p = swap_info[type];
@@ -3358,7 +3365,7 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
 {
 	struct swap_info_struct *p;
 	struct swap_cluster_info *ci;
-	unsigned long offset, type;
+	unsigned long offset;
 	unsigned char count;
 	unsigned char has_cache;
 	int err = -EINVAL;
@@ -3366,10 +3373,10 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
 	if (non_swap_entry(entry))
 		goto out;
 
-	type = swp_type(entry);
-	if (type >= nr_swapfiles)
+	p = swp_swap_info(entry);
+	if (!p)
 		goto bad_file;
-	p = swap_info[type];
+
 	offset = swp_offset(entry);
 	if (unlikely(offset >= p->max))
 		goto out;
@@ -3466,7 +3473,7 @@ int swapcache_prepare(swp_entry_t entry)
 
 struct swap_info_struct *swp_swap_info(swp_entry_t entry)
 {
-	return swap_info[swp_type(entry)];
+	return swap_type_to_swap_info(swp_type(entry));
 }
 
 struct swap_info_struct *page_swap_info(struct page *page)
-- 
2.19.1

