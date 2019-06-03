Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 617ABC468BC
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 13:22:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2755625C0B
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 13:22:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2755625C0B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CA806B0006; Mon,  3 Jun 2019 09:22:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07BAF6B0008; Mon,  3 Jun 2019 09:22:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E66916B000A; Mon,  3 Jun 2019 09:22:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 86F856B0006
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 09:22:05 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d13so15867823edo.5
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 06:22:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=NUY22rD3X9mHz9jt1gNSoADUzA2AdsUNRnxzsaOlAls=;
        b=N2RqG0VN/vxa+MPIg27FbxBhLbxbIvu0Z29RuMoUTBzZklQCe2VrW0ttXt57UWQq9d
         jCG30QOTqKKtSL1JlfqcH9NlCUKsZn4k2CFGf/6C3UWhegA7JEWDjeZ3DYKUeBZ+Q5/z
         6pKIOaaLlqsx+OakVQPzLcYNq4hJBoWGuznuDEu3Dhl9HJdss2alg94UoKvd8LJK8mnk
         lz8TwmFld30QNrw6C/Hq0CEqcWTa6FuM0css292JkRZMxZMLnkt6QCbq70umBAFa3dhF
         WTf7uD3eZ7Orzheil+QKWOAibbzARJKM9JRpv2KuAPKLxs1tlBun1OBxSngCEE3Lm4uk
         XIMw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAVwnvqr/oPZJymRCmGHr8d0gnGa0mEXglMP1eNT//PVOkPNO4Fx
	9YaG/bSlJVXUrwwyRQAETSrzxllnlgMLqK9PaJ+7QU3QCbhcd0BBhdqw6NVSV8V1XZurgWm6sU0
	DSFjpw2gPPuN2iDm21xbIlrg2plQLCVZTAuW/01p+ByBwqCEaJm6EKQ+wWneCQaiahg==
X-Received: by 2002:a50:ee01:: with SMTP id g1mr27970925eds.263.1559568125001;
        Mon, 03 Jun 2019 06:22:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpbKpZHGwRAKmwB+y25/c+mCSxPeYtQ1DgRCLg/q3c0S7U771uqUkQ0dbE/pDpvowsoB6U
X-Received: by 2002:a50:ee01:: with SMTP id g1mr27970792eds.263.1559568123608;
        Mon, 03 Jun 2019 06:22:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559568123; cv=none;
        d=google.com; s=arc-20160816;
        b=DLsjFVV6S04dTqGukjU55qhbByHHD79nxN82i4DCruI6ezQt8F4VmY0B/kmccyDEYz
         /NckFsnzdiF30lM4Yh38phYuS9+Q+IeGYF4yU/zKb3WXNp7/WuMZieo/8OSCWxf6P7pS
         b/TP8Y1qY/5CwrVbPm42SdAila2e/3TUnKXTafKRkaL3qlf2AQekZijTarYHxK+vJTvt
         fCDZKLwIoo4A4L41+2ppZimR/NFSVaX6r8LZxHfrI446kXAvBWUzvKlQZss1h4GxSrxq
         gKoPXQTEe5VQGG++SwIGENC6qrMYhLS3SoUQWPmeEmDB5UetQWtIe93ebqAYUI9A2Y8t
         VtoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=NUY22rD3X9mHz9jt1gNSoADUzA2AdsUNRnxzsaOlAls=;
        b=cgH4gWPIuQaQB7dak/irAUPMbv3iLjNqyz+ZvHryvNwm8lm79M76CHy+WbX7535O3N
         4AKZtNpi9AE0LA1qjSTMTnTK2z/LvSpVyVE8X9OTP/xqtD8zV28MLdLkvlIKjJFmQFpW
         MLrAEYIm38Namhh1ufaIzmCnwE/pyZL5Ye4qLkN1Q9Ypn14xHwUB9NrIAdxyFSyo15kS
         fPqZYAfmpQHm4bWgqRedleTPfdPhlIcx8vvUScW7QJtJeCTDe1VMyfl7h5q5uJm5Jox/
         jXQPAPivmqQ83n4EbBFuG0gyjCgeMa3m4t/CYhy/FcBc91+vK9oFx5VY6b/zY/lZIDCF
         uL7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 9si1797948ejx.127.2019.06.03.06.22.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 06:22:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 325BCADC4;
	Mon,  3 Jun 2019 13:22:03 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 4E8AB1E0DBA; Mon,  3 Jun 2019 15:22:00 +0200 (CEST)
From: Jan Kara <jack@suse.cz>
To: <linux-ext4@vger.kernel.org>
Cc: Ted Tso <tytso@mit.edu>,
	<linux-mm@kvack.org>,
	<linux-fsdevel@vger.kernel.org>,
	Amir Goldstein <amir73il@gmail.com>,
	Jan Kara <jack@suse.cz>,
	stable@vger.kernel.org
Subject: [PATCH 1/2] mm: Add readahead file operation
Date: Mon,  3 Jun 2019 15:21:54 +0200
Message-Id: <20190603132155.20600-2-jack@suse.cz>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190603132155.20600-1-jack@suse.cz>
References: <20190603132155.20600-1-jack@suse.cz>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Some filesystems need to acquire locks before pages are read into page
cache to protect from races with hole punching. The lock generally
cannot be acquired within readpage as it ranks above page lock so we are
left with acquiring the lock within filesystem's ->read_iter
implementation for normal reads and ->fault implementation during page
faults. That however does not cover all paths how pages can be
instantiated within page cache - namely explicitely requested readahead.
Add new ->readahead file operation which filesystem can use for this.

CC: stable@vger.kernel.org # Needed by following ext4 fix
Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/fs.h |  5 +++++
 include/linux/mm.h |  3 ---
 mm/fadvise.c       | 12 +-----------
 mm/madvise.c       |  3 ++-
 mm/readahead.c     | 26 ++++++++++++++++++++++++--
 5 files changed, 32 insertions(+), 17 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index f7fdfe93e25d..9968abcd06ea 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1828,6 +1828,7 @@ struct file_operations {
 				   struct file *file_out, loff_t pos_out,
 				   loff_t len, unsigned int remap_flags);
 	int (*fadvise)(struct file *, loff_t, loff_t, int);
+	int (*readahead)(struct file *, loff_t, loff_t);
 } __randomize_layout;
 
 struct inode_operations {
@@ -3537,6 +3538,10 @@ extern void inode_nohighmem(struct inode *inode);
 extern int vfs_fadvise(struct file *file, loff_t offset, loff_t len,
 		       int advice);
 
+/* mm/readahead.c */
+extern int generic_readahead(struct file *filp, loff_t start, loff_t end);
+extern int vfs_readahead(struct file *filp, loff_t start, loff_t end);
+
 #if defined(CONFIG_IO_URING)
 extern struct sock *io_uring_get_socket(struct file *file);
 #else
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0e8834ac32b7..8f6597295920 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2461,9 +2461,6 @@ void task_dirty_inc(struct task_struct *tsk);
 /* readahead.c */
 #define VM_READAHEAD_PAGES	(SZ_128K / PAGE_SIZE)
 
-int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
-			pgoff_t offset, unsigned long nr_to_read);
-
 void page_cache_sync_readahead(struct address_space *mapping,
 			       struct file_ra_state *ra,
 			       struct file *filp,
diff --git a/mm/fadvise.c b/mm/fadvise.c
index 467bcd032037..e5aab207550e 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -36,7 +36,6 @@ static int generic_fadvise(struct file *file, loff_t offset, loff_t len,
 	loff_t endbyte;			/* inclusive */
 	pgoff_t start_index;
 	pgoff_t end_index;
-	unsigned long nrpages;
 
 	inode = file_inode(file);
 	if (S_ISFIFO(inode->i_mode))
@@ -94,20 +93,11 @@ static int generic_fadvise(struct file *file, loff_t offset, loff_t len,
 		spin_unlock(&file->f_lock);
 		break;
 	case POSIX_FADV_WILLNEED:
-		/* First and last PARTIAL page! */
-		start_index = offset >> PAGE_SHIFT;
-		end_index = endbyte >> PAGE_SHIFT;
-
-		/* Careful about overflow on the "+1" */
-		nrpages = end_index - start_index + 1;
-		if (!nrpages)
-			nrpages = ~0UL;
-
 		/*
 		 * Ignore return value because fadvise() shall return
 		 * success even if filesystem can't retrieve a hint,
 		 */
-		force_page_cache_readahead(mapping, file, start_index, nrpages);
+		vfs_readahead(file, offset, endbyte);
 		break;
 	case POSIX_FADV_NOREUSE:
 		break;
diff --git a/mm/madvise.c b/mm/madvise.c
index 628022e674a7..9111b75e88cf 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -303,7 +303,8 @@ static long madvise_willneed(struct vm_area_struct *vma,
 		end = vma->vm_end;
 	end = ((end - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 
-	force_page_cache_readahead(file->f_mapping, file, start, end - start);
+	vfs_readahead(file, (loff_t)start << PAGE_SHIFT,
+		      (loff_t)end << PAGE_SHIFT);
 	return 0;
 }
 
diff --git a/mm/readahead.c b/mm/readahead.c
index 2fe72cd29b47..e66ae8c764ad 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -219,8 +219,9 @@ unsigned int __do_page_cache_readahead(struct address_space *mapping,
  * Chunk the readahead into 2 megabyte units, so that we don't pin too much
  * memory at once.
  */
-int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
-			       pgoff_t offset, unsigned long nr_to_read)
+static int force_page_cache_readahead(struct address_space *mapping,
+				      struct file *filp, pgoff_t offset,
+				      unsigned long nr_to_read)
 {
 	struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
 	struct file_ra_state *ra = &filp->f_ra;
@@ -248,6 +249,20 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	return 0;
 }
 
+int generic_readahead(struct file *filp, loff_t start, loff_t end)
+{
+	pgoff_t first, last;
+	unsigned long count;
+
+	first = start >> PAGE_SHIFT;
+	last = end >> PAGE_SHIFT;
+	count = last - first + 1;
+	if (!count)
+		count = ~0UL;
+	return force_page_cache_readahead(filp->f_mapping, filp, first, count);
+}
+EXPORT_SYMBOL_GPL(generic_readahead);
+
 /*
  * Set the initial window size, round to next power of 2 and square
  * for small size, x 4 for medium, and x 2 for large
@@ -575,6 +590,13 @@ page_cache_async_readahead(struct address_space *mapping,
 }
 EXPORT_SYMBOL_GPL(page_cache_async_readahead);
 
+int vfs_readahead(struct file *filp, loff_t start, loff_t end)
+{
+	if (filp->f_op->readahead)
+		return filp->f_op->readahead(filp, start, end);
+	return generic_readahead(filp, start, end);
+}
+
 ssize_t ksys_readahead(int fd, loff_t offset, size_t count)
 {
 	ssize_t ret;
-- 
2.16.4

