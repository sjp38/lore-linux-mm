Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D051C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:57:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BC072084D
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:57:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XEiIETwR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BC072084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E15FF6B0275; Thu, 15 Aug 2019 15:57:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC64B6B027A; Thu, 15 Aug 2019 15:57:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDC0A6B027C; Thu, 15 Aug 2019 15:57:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0140.hostedemail.com [216.40.44.140])
	by kanga.kvack.org (Postfix) with ESMTP id ACAEA6B0275
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 15:57:53 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 5F708181AC9AE
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:57:53 +0000 (UTC)
X-FDA: 75825722826.08.stove05_a9e23506b055
X-HE-Tag: stove05_a9e23506b055
X-Filterd-Recvd-Size: 7385
Received: from mail-qk1-f193.google.com (mail-qk1-f193.google.com [209.85.222.193])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:57:52 +0000 (UTC)
Received: by mail-qk1-f193.google.com with SMTP id p13so2786666qkg.13
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 12:57:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=NK0PK6csvakTjylMz8jDV7zgrirY2g6A6SS9gcMGP38=;
        b=XEiIETwR/iRc/lXiBJkeGJWLPwdP3OTZNZTIZNNbaUyYnuuBUMWk76hAjCesVsGRvR
         DVIXJNeKmQfqKXW702SF1PUeP9sMQBQHvirBaKtwjRZq+JeR2Bqiqj8abtcJSMCd1jzQ
         70f4yD1051JXCEGH8Jf4XgvdEGl7z6LtJqxDO8gRemoNlh+IeCfl8mEaqjzVNU4JR8CL
         rQRPxZoa84hi4tZtGQDIy5KO8uZu8JaNvj9NPih9o3iaXsNOSBCo6teWiZ/GbCdlfiuX
         p4mSuilXdKhg1WbG1k1KNt5O/wZddMSeF2o9jyOlaEWhRejaiNoKnop+vbB73UpmszkK
         DYkw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=NK0PK6csvakTjylMz8jDV7zgrirY2g6A6SS9gcMGP38=;
        b=oQVh6Zn+OzSBjbK1knpD0T+9wB9L8MM6z647+iFBY14tXGtAz1KAgGYksfytJG0F7p
         VFyrvJL4ZzPrE2Ilkf8k6lS8OyvRSs5pnpbF9KFM7ZqMHTCTRq0Csgnq3QYNoPlALuoW
         vjvYptUAj/PUw4CXxd30YySwnyXTh5Zo8Oy7AORc4RmKb3BkPrb1LyzPno022Or1NoDN
         T9yIeFCPGSqlCyLeOxTT1eXJwKbtyLJj4GWHT/y2yWcqRCuOHZxgGhDlPbotxDr2TQPw
         vhz0gU1D2PqSwZi7cETKn9u1GEktVBcNv0iVneqVofAil524jDDmRYARDxuKPC9FOxwg
         wUxA==
X-Gm-Message-State: APjAAAWEmHa8AuDfEy4sPy82GCAUntE3KVRoBSQ8ZlAW9u8W+wm6onCG
	nku/bO+ikuWqiw+Dwc8RLbI=
X-Google-Smtp-Source: APXvYqxgqkXzG03UW+nQ2wzQV8lJWn1lUi6WbNWPWMtyk1a9ytxbt9vAVv4HDVD3hmWenqlqAUYrlw==
X-Received: by 2002:ae9:e411:: with SMTP id q17mr5416347qkc.465.1565899072231;
        Thu, 15 Aug 2019 12:57:52 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:25cd])
        by smtp.gmail.com with ESMTPSA id o21sm1768914qkk.100.2019.08.15.12.57.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Aug 2019 12:57:51 -0700 (PDT)
Date: Thu, 15 Aug 2019 12:57:50 -0700
From: Tejun Heo <tj@kernel.org>
To: axboe@kernel.dk, jack@suse.cz, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com, akpm@linux-foundation.org
Subject: [PATCH 2/5] bdi: Add bdi->id
Message-ID: <20190815195750.GC2263813@devbig004.ftw2.facebook.com>
References: <20190815195619.GA2263813@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815195619.GA2263813@devbig004.ftw2.facebook.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There currently is no way to universally identify and lookup a bdi
without holding a reference and pointer to it.  This patch adds an
non-recycling bdi->id and implements bdi_get_by_id() which looks up
bdis by their ids.  This will be used by memcg foreign inode flushing.

I left bdi_list alone for simplicity and because while rb_tree does
support rcu assignment it doesn't seem to guarantee lossless walk when
walk is racing aginst tree rebalance operations.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 include/linux/backing-dev-defs.h |    2 +
 include/linux/backing-dev.h      |    1 
 mm/backing-dev.c                 |   65 +++++++++++++++++++++++++++++++++++++--
 3 files changed, 66 insertions(+), 2 deletions(-)

--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -185,6 +185,8 @@ struct bdi_writeback {
 };
 
 struct backing_dev_info {
+	u64 id;
+	struct rb_node rb_node; /* keyed by ->id */
 	struct list_head bdi_list;
 	unsigned long ra_pages;	/* max readahead in PAGE_SIZE units */
 	unsigned long io_pages;	/* max allowed IO size */
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -24,6 +24,7 @@ static inline struct backing_dev_info *b
 	return bdi;
 }
 
+struct backing_dev_info *bdi_get_by_id(u64 id);
 void bdi_put(struct backing_dev_info *bdi);
 
 __printf(2, 3)
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -1,6 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0-only
 
 #include <linux/wait.h>
+#include <linux/rbtree.h>
 #include <linux/backing-dev.h>
 #include <linux/kthread.h>
 #include <linux/freezer.h>
@@ -22,10 +23,12 @@ EXPORT_SYMBOL_GPL(noop_backing_dev_info)
 static struct class *bdi_class;
 
 /*
- * bdi_lock protects updates to bdi_list. bdi_list has RCU reader side
- * locking.
+ * bdi_lock protects bdi_tree and updates to bdi_list. bdi_list has RCU
+ * reader side locking.
  */
 DEFINE_SPINLOCK(bdi_lock);
+static u64 bdi_id_cursor;
+static struct rb_root bdi_tree = RB_ROOT;
 LIST_HEAD(bdi_list);
 
 /* bdi_wq serves all asynchronous writeback tasks */
@@ -859,9 +862,58 @@ struct backing_dev_info *bdi_alloc_node(
 }
 EXPORT_SYMBOL(bdi_alloc_node);
 
+static struct rb_node **bdi_lookup_rb_node(u64 id, struct rb_node **parentp)
+{
+	struct rb_node **p = &bdi_tree.rb_node;
+	struct rb_node *parent = NULL;
+	struct backing_dev_info *bdi;
+
+	lockdep_assert_held(&bdi_lock);
+
+	while (*p) {
+		parent = *p;
+		bdi = rb_entry(parent, struct backing_dev_info, rb_node);
+
+		if (bdi->id > id)
+			p = &(*p)->rb_left;
+		else if (bdi->id < id)
+			p = &(*p)->rb_right;
+		else
+			break;
+	}
+
+	if (parentp)
+		*parentp = parent;
+	return p;
+}
+
+/**
+ * bdi_get_by_id - lookup and get bdi from its id
+ * @id: bdi id to lookup
+ *
+ * Find bdi matching @id and get it.  Returns NULL if the matching bdi
+ * doesn't exist or is already unregistered.
+ */
+struct backing_dev_info *bdi_get_by_id(u64 id)
+{
+	struct backing_dev_info *bdi = NULL;
+	struct rb_node **p;
+
+	spin_lock_bh(&bdi_lock);
+	p = bdi_lookup_rb_node(id, NULL);
+	if (*p) {
+		bdi = rb_entry(*p, struct backing_dev_info, rb_node);
+		bdi_get(bdi);
+	}
+	spin_unlock_bh(&bdi_lock);
+
+	return bdi;
+}
+
 int bdi_register_va(struct backing_dev_info *bdi, const char *fmt, va_list args)
 {
 	struct device *dev;
+	struct rb_node *parent, **p;
 
 	if (bdi->dev)	/* The driver needs to use separate queues per device */
 		return 0;
@@ -877,7 +929,15 @@ int bdi_register_va(struct backing_dev_i
 	set_bit(WB_registered, &bdi->wb.state);
 
 	spin_lock_bh(&bdi_lock);
+
+	bdi->id = ++bdi_id_cursor;
+
+	p = bdi_lookup_rb_node(bdi->id, &parent);
+	rb_link_node(&bdi->rb_node, parent, p);
+	rb_insert_color(&bdi->rb_node, &bdi_tree);
+
 	list_add_tail_rcu(&bdi->bdi_list, &bdi_list);
+
 	spin_unlock_bh(&bdi_lock);
 
 	trace_writeback_bdi_register(bdi);
@@ -918,6 +978,7 @@ EXPORT_SYMBOL(bdi_register_owner);
 static void bdi_remove_from_list(struct backing_dev_info *bdi)
 {
 	spin_lock_bh(&bdi_lock);
+	rb_erase(&bdi->rb_node, &bdi_tree);
 	list_del_rcu(&bdi->bdi_list);
 	spin_unlock_bh(&bdi_lock);
 

