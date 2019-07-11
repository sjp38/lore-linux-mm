Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DF80C74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 12:58:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B056F21019
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 12:58:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B056F21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1FD488E00B9; Thu, 11 Jul 2019 08:58:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1AEB88E0032; Thu, 11 Jul 2019 08:58:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C32E8E00B9; Thu, 11 Jul 2019 08:58:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AFDAB8E0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 08:58:47 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i44so4596070eda.3
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 05:58:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=thC+Fh6DfUo8m/CJvDqq2ng1J/XAIuAmbvJp2KrXMpw=;
        b=GUU7ojmSOjP9czaPhs5n2a78TdsSJ57BCrwO0ocJ68x0InH0l56eyvxRkz9yk/cXR1
         MjZKG0+OaezY6hvUGVvjiTntRZaZBwT5gjx59uXNu4Y1Zy840zC6irT7aW49Sk1GawS2
         994Zxt9xMJcv6rLfqKW5+fNvcOM/Mo1k8gSccfu9Rnh7DiLTx2bOtqqjcH631761RT1s
         1VpLYVFPpMCDwvO8PhkQiR9U1x61x0gjklkgFvu1XtiWs7NiPJAMauzdHpnyxGn+Sxqi
         DjS9/yLvPz9bKQWs/tomBdK0r+JV+CmwYS6h2+GLd57B5q/oAb1iTyLjjqSDOnCNDssF
         +Cvw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAXHXA48srm15ldemjP4SOssm9miZxrNTJiNREVIkTvVBFesF2bA
	FNbS2cgUi20MZN8cacczUndx3jJ72EHSRhrtr+cvI9JhRC8y3GvnfCZuc90Hwqv/0waroz9iH7d
	MxkromGSRhJg/fkMLjOQtuhHrsrmLnhVUpMgdWT6nNbJSCvTrdf1Y5Ts08MslevzyCA==
X-Received: by 2002:a17:906:fac5:: with SMTP id lu5mr3040202ejb.295.1562849927089;
        Thu, 11 Jul 2019 05:58:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpLI4w8Ie402EuxsxxbmhSGyahY2sHFAboeFvR3u5T4PIM3LzCwqgMSN72BCr3bAPf20Iw
X-Received: by 2002:a17:906:fac5:: with SMTP id lu5mr3040140ejb.295.1562849925837;
        Thu, 11 Jul 2019 05:58:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562849925; cv=none;
        d=google.com; s=arc-20160816;
        b=PQhMPor4Vxs0wpFagjd5/dPVLsLE3E1a6oHR3jAAVNjTKO3uB7vsMKEH5miK8Oko77
         i/bWOKgH7Z7LuL1bwSiun1/js2oURfOg5xrpd6k8sYuJD7eJQCNNqCB54aTMMeTyGLAi
         fMKcAUEhAAkuU3x+yF/G0NKZB5+bEo9wVQVRQq+ES/fHhPq3G++cstCxMHhM5O+FP1XG
         xx/RpVUy13M7/7aE4XQo4iaWC8mQG35WPcHcaE6ITCEK8696vD++U0A/fOPEeknmfPFV
         6TbxQ3FbAsG1aBGy/MZSDyCwIwTlRpHJUK6vSOAza1U4CWOR+3jXCZet/nZbvRaGFA91
         CXhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=thC+Fh6DfUo8m/CJvDqq2ng1J/XAIuAmbvJp2KrXMpw=;
        b=RJWLg97n7GmsqBboEqpH1OOXRpgXI/LcjwmZuBfGG5MJPexTs15NXOog8gSCuuEgA3
         BzNFfZPyoHOcE63iop+Ld8b7FZImXazx3imMG7iu5eeJrithS4tUjJwwi3ZQPwoSI2PD
         5aV4Inp3EpWEBcXDkLXxyglXBdN/dLaHZ/jsgKALzoKrIS9dGN+VK/hZfZq9tW5UCbUg
         GxUv6z/LXP75b9/jpxuFHFjGqgZDuMoQYypPft4cLhB1x9IOwRWa/NptG6p0YpPdD/4o
         Mn84Jnp61QUitNcdZIebZvLaXcMdc/G4XzY9jW/j9saUGsfiYDYpnwW2V2SbhoYdUMuh
         M6Sg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m14si3459436edc.388.2019.07.11.05.58.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 05:58:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0D8C6B12A;
	Thu, 11 Jul 2019 12:58:45 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 3734F1E43CB; Thu, 11 Jul 2019 14:58:44 +0200 (CEST)
From: Jan Kara <jack@suse.cz>
To: <linux-mm@kvack.org>
Cc: mgorman@suse.de,
	mhocko@suse.cz,
	Andrew Morton <akpm@linux-foundation.org>,
	Jan Kara <jack@suse.cz>,
	stable@vger.kernel.org
Subject: [PATCH RFC] mm: migrate: Fix races of __find_get_block() and page migration
Date: Thu, 11 Jul 2019 14:58:38 +0200
Message-Id: <20190711125838.32565-1-jack@suse.cz>
X-Mailer: git-send-email 2.16.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

buffer_migrate_page_norefs() can race with bh users in a following way:

CPU1					CPU2
buffer_migrate_page_norefs()
  buffer_migrate_lock_buffers()
  checks bh refs
  spin_unlock(&mapping->private_lock)
					__find_get_block()
					  spin_lock(&mapping->private_lock)
					  grab bh ref
					  spin_unlock(&mapping->private_lock)
  move page				  do bh work

This can result in various issues like lost updates to buffers (i.e.
metadata corruption) or use after free issues for the old page.

Closing this race window is relatively difficult. We could hold
mapping->private_lock in buffer_migrate_page_norefs() until we are
finished with migrating the page but the lock hold times would be rather
big. So let's revert to a more careful variant of page migration requiring
eviction of buffers on migrated page. This is effectively
fallback_migrate_page() that additionally invalidates bh LRUs in case
try_to_free_buffers() failed.

CC: stable@vger.kernel.org
Fixes: 89cb0888ca14 "mm: migrate: provide buffer_migrate_page_norefs()"
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/migrate.c | 161 +++++++++++++++++++++++++++++------------------------------
 1 file changed, 78 insertions(+), 83 deletions(-)

I've lightly tested this with config-workload-thpfioscale which didn't
show any obvious issue but the patch probably needs more testing (especially
to verify that memory unplug is still able to succeed in reasonable time).
That's why this is RFC.

diff --git a/mm/migrate.c b/mm/migrate.c
index e9594bc0d406..893698d37d50 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -697,6 +697,47 @@ int migrate_page(struct address_space *mapping,
 }
 EXPORT_SYMBOL(migrate_page);
 
+/*
+ * Writeback a page to clean the dirty state
+ */
+static int writeout(struct address_space *mapping, struct page *page)
+{
+	struct writeback_control wbc = {
+		.sync_mode = WB_SYNC_NONE,
+		.nr_to_write = 1,
+		.range_start = 0,
+		.range_end = LLONG_MAX,
+		.for_reclaim = 1
+	};
+	int rc;
+
+	if (!mapping->a_ops->writepage)
+		/* No write method for the address space */
+		return -EINVAL;
+
+	if (!clear_page_dirty_for_io(page))
+		/* Someone else already triggered a write */
+		return -EAGAIN;
+
+	/*
+	 * A dirty page may imply that the underlying filesystem has
+	 * the page on some queue. So the page must be clean for
+	 * migration. Writeout may mean we loose the lock and the
+	 * page state is no longer what we checked for earlier.
+	 * At this point we know that the migration attempt cannot
+	 * be successful.
+	 */
+	remove_migration_ptes(page, page, false);
+
+	rc = mapping->a_ops->writepage(page, &wbc);
+
+	if (rc != AOP_WRITEPAGE_ACTIVATE)
+		/* unlocked. Relock */
+		lock_page(page);
+
+	return (rc < 0) ? -EIO : -EAGAIN;
+}
+
 #ifdef CONFIG_BLOCK
 /* Returns true if all buffers are successfully locked */
 static bool buffer_migrate_lock_buffers(struct buffer_head *head,
@@ -736,9 +777,14 @@ static bool buffer_migrate_lock_buffers(struct buffer_head *head,
 	return true;
 }
 
-static int __buffer_migrate_page(struct address_space *mapping,
-		struct page *newpage, struct page *page, enum migrate_mode mode,
-		bool check_refs)
+/*
+ * Migration function for pages with buffers. This function can only be used
+ * if the underlying filesystem guarantees that no other references to "page"
+ * exist. For example attached buffer heads are accessed only under page lock.
+ */
+int buffer_migrate_page(struct address_space *mapping,
+			struct page *newpage, struct page *page,
+			enum migrate_mode mode)
 {
 	struct buffer_head *bh, *head;
 	int rc;
@@ -756,33 +802,6 @@ static int __buffer_migrate_page(struct address_space *mapping,
 	if (!buffer_migrate_lock_buffers(head, mode))
 		return -EAGAIN;
 
-	if (check_refs) {
-		bool busy;
-		bool invalidated = false;
-
-recheck_buffers:
-		busy = false;
-		spin_lock(&mapping->private_lock);
-		bh = head;
-		do {
-			if (atomic_read(&bh->b_count)) {
-				busy = true;
-				break;
-			}
-			bh = bh->b_this_page;
-		} while (bh != head);
-		spin_unlock(&mapping->private_lock);
-		if (busy) {
-			if (invalidated) {
-				rc = -EAGAIN;
-				goto unlock_buffers;
-			}
-			invalidate_bh_lrus();
-			invalidated = true;
-			goto recheck_buffers;
-		}
-	}
-
 	rc = migrate_page_move_mapping(mapping, newpage, page, mode, 0);
 	if (rc != MIGRATEPAGE_SUCCESS)
 		goto unlock_buffers;
@@ -818,72 +837,48 @@ static int __buffer_migrate_page(struct address_space *mapping,
 
 	return rc;
 }
-
-/*
- * Migration function for pages with buffers. This function can only be used
- * if the underlying filesystem guarantees that no other references to "page"
- * exist. For example attached buffer heads are accessed only under page lock.
- */
-int buffer_migrate_page(struct address_space *mapping,
-		struct page *newpage, struct page *page, enum migrate_mode mode)
-{
-	return __buffer_migrate_page(mapping, newpage, page, mode, false);
-}
 EXPORT_SYMBOL(buffer_migrate_page);
 
 /*
- * Same as above except that this variant is more careful and checks that there
- * are also no buffer head references. This function is the right one for
- * mappings where buffer heads are directly looked up and referenced (such as
- * block device mappings).
+ * Same as above except that this variant is more careful.  This function is
+ * the right one for mappings where buffer heads are directly looked up and
+ * referenced (such as block device mappings).
  */
 int buffer_migrate_page_norefs(struct address_space *mapping,
 		struct page *newpage, struct page *page, enum migrate_mode mode)
 {
-	return __buffer_migrate_page(mapping, newpage, page, mode, true);
-}
-#endif
-
-/*
- * Writeback a page to clean the dirty state
- */
-static int writeout(struct address_space *mapping, struct page *page)
-{
-	struct writeback_control wbc = {
-		.sync_mode = WB_SYNC_NONE,
-		.nr_to_write = 1,
-		.range_start = 0,
-		.range_end = LLONG_MAX,
-		.for_reclaim = 1
-	};
-	int rc;
-
-	if (!mapping->a_ops->writepage)
-		/* No write method for the address space */
-		return -EINVAL;
+	bool invalidated = false;
 
-	if (!clear_page_dirty_for_io(page))
-		/* Someone else already triggered a write */
-		return -EAGAIN;
+	if (PageDirty(page)) {
+		/* Only writeback pages in full synchronous migration */
+		switch (mode) {
+		case MIGRATE_SYNC:
+		case MIGRATE_SYNC_NO_COPY:
+			break;
+		default:
+			return -EBUSY;
+		}
+		return writeout(mapping, page);
+	}
 
+retry:
 	/*
-	 * A dirty page may imply that the underlying filesystem has
-	 * the page on some queue. So the page must be clean for
-	 * migration. Writeout may mean we loose the lock and the
-	 * page state is no longer what we checked for earlier.
-	 * At this point we know that the migration attempt cannot
-	 * be successful.
+	 * Buffers may be managed in a filesystem specific way.
+	 * We must have no buffers or drop them.
 	 */
-	remove_migration_ptes(page, page, false);
-
-	rc = mapping->a_ops->writepage(page, &wbc);
-
-	if (rc != AOP_WRITEPAGE_ACTIVATE)
-		/* unlocked. Relock */
-		lock_page(page);
+	if (page_has_private(page) &&
+	    !try_to_release_page(page, GFP_KERNEL)) {
+		if (!invalidated) {
+			invalidate_bh_lrus();
+			invalidated = true;
+			goto retry;
+		}
+		return mode == MIGRATE_SYNC ? -EAGAIN : -EBUSY;
+	}
 
-	return (rc < 0) ? -EIO : -EAGAIN;
+	return migrate_page(mapping, newpage, page, mode);
 }
+#endif
 
 /*
  * Default handling if a filesystem does not provide a migration function.
-- 
2.16.4

