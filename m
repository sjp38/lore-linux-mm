Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 528BCC32753
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0762A20693
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0762A20693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E85B68E0003; Wed, 31 Jul 2019 22:18:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B66F28E0012; Wed, 31 Jul 2019 22:18:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E4F08E0013; Wed, 31 Jul 2019 22:18:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0D72C8E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:18:12 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i26so44536721pfo.22
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:18:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dYkokhGzchvhh8AlOQN79KnC+lI3UhM86uN2hNPC9ko=;
        b=m/XA1q4TpWi+C5ReGP55tp0E/mqhj7niq0nntlZuicdT09d8elWSqRFPqOLssNcHqv
         MGSq+WgHc/EAcsq+xykE4UE7sKZSN6pZj5bRA+GZmeZhSEqZU/nyv0gZl2QH4+JWKzFU
         KdxkS7+HuDV0B1XN9TpjF8I3lHNaMV5h1kNiJLxfPimHYnYESLPiPR1lpG7gqb/h0W6A
         5+8kVE5itYTTz60BJQ9fitv/r0DF63fLtxn7LAjQXnjf7IipZyVuRmuVAGNetq9ZtxRl
         3BM/QgQ2+iryvLAyo8FsFH2eRqdkESXywyYqI9iOZUcmr8JzOef4Tba2bbYEGP1iUsXn
         qcaw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXddS8a2xw52Ns154pA/LZnrjW5T3RbvzX82uKVyGxL0+Y/W8Cg
	ELGW8Z/cThr0z8TaBZEPzoEOsZo3nqi5hKz6oGCFWz2304Hl/uAPVYNXLqg7m4OVRguWaB7AOzp
	TybydnGukiRNZNdcfQ0ttfBfk3UoQjJuwOtx1VsjeoEJo9vY+XpTdH3h0GLz/tEY=
X-Received: by 2002:a63:b20f:: with SMTP id x15mr7744325pge.453.1564625891591;
        Wed, 31 Jul 2019 19:18:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcIzUyRxCKOwu2qU5DgcG5/FcXSfKr3udnPyTN/ABliJtiaTB093sZ8O1zGoPUPD+mIDbS
X-Received: by 2002:a63:b20f:: with SMTP id x15mr7743849pge.453.1564625881632;
        Wed, 31 Jul 2019 19:18:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564625881; cv=none;
        d=google.com; s=arc-20160816;
        b=rbY9LmzCfZzDhd5E4wOMyDAJu6SAAu5d0zdjuAtGpU48OSrdQdCZpwGrhvQGo+QY5l
         Zza8XpvZh4vNLMEuUGZAMB5fybAg0u8Odtpf51Kb5NNNrkpVWt9xQtmv7Nuub/Mxk7FB
         Aizowf2olphiBXaXhySP76CStssa/iMZGE+tAvRV9qiY8hNLJHewa2hGWiD2Y3YOaRn5
         qJCMmRs5hg5A2QVc0B5EGo7mGagGDHwE77OzOBrgFSaCOhsnmCXNvSjdgfPOekoa+BzT
         8VnX0xEzp0CYsLkGTOrzjxM7xuo2o4To5ZB0gd0RvfmIAf87lpiMO0QoPBcCcXwNwSpT
         pbPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=dYkokhGzchvhh8AlOQN79KnC+lI3UhM86uN2hNPC9ko=;
        b=EpAmodlkNfIrQSQy6pCeiqKWYKTMI8VnJMQk9baIqu/gjm5+QhG1g5uKAORMA4AtEB
         bh2Ny6inwwjTi+H4eKZUhFZUVz4ByunEI+ejFzXo2IeD8c8rnTni0JBCtvO2xy1T5OqB
         VTqJQZvvpxusWH3/wVRv4iXwWaqhTDAH+NAyQeNLDrMbE0qJ+18PMkvS2LPvxFk++IA/
         tjljm6QW8K7/xZNBcRuj0/dzaO1qZn6iZ7l+2Vj5hQe3Ew9OWn/Z+rTrWKk4jPhymcDl
         cPIfrGne8eGfjoW3wEkX5RdFMPj+syNLgHRjUbI42p7bvz5cTEC+cL58UDdz656FmHMo
         YX3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id r8si35955754pgr.243.2019.07.31.19.18.01
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 19:18:01 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id B23C543DD1A;
	Thu,  1 Aug 2019 12:17:57 +1000 (AEST)
Received: from discord.disaster.area ([192.168.253.110])
	by dread.disaster.area with esmtp (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0eA-0003aQ-OS; Thu, 01 Aug 2019 12:16:50 +1000
Received: from dave by discord.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0fG-0001kb-MB; Thu, 01 Aug 2019 12:17:58 +1000
From: Dave Chinner <david@fromorbit.com>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH 02/24] shrinkers: use will_defer for GFP_NOFS sensitive shrinkers
Date: Thu,  1 Aug 2019 12:17:30 +1000
Message-Id: <20190801021752.4986-3-david@fromorbit.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801021752.4986-1-david@fromorbit.com>
References: <20190801021752.4986-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=FmdZ9Uzk2mMA:10 a=20KFwNOVAAAA:8
	a=bIsfdx-f5ddGStTJopEA:9
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

For shrinkers that currently avoid scanning when called under
GFP_NOFS contexts, conver them to use the new ->will_defer flag
rather than checking and returning errors during scans.

This makes it very clear that these shrinkers are not doing any work
because of the context limitations, not because there is no work
that can be done.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 drivers/staging/android/ashmem.c |  8 ++++----
 fs/gfs2/glock.c                  |  5 +++--
 fs/gfs2/quota.c                  |  6 +++---
 fs/nfs/dir.c                     |  6 +++---
 fs/super.c                       |  6 +++---
 fs/xfs/xfs_buf.c                 |  4 ++++
 fs/xfs/xfs_qm.c                  | 11 ++++++++---
 net/sunrpc/auth.c                |  5 ++---
 8 files changed, 30 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index 74d497d39c5a..fd9027dbd28c 100644
--- a/drivers/staging/android/ashmem.c
+++ b/drivers/staging/android/ashmem.c
@@ -438,10 +438,6 @@ ashmem_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 {
 	unsigned long freed = 0;
 
-	/* We might recurse into filesystem code, so bail out if necessary */
-	if (!(sc->gfp_mask & __GFP_FS))
-		return SHRINK_STOP;
-
 	if (!mutex_trylock(&ashmem_mutex))
 		return -1;
 
@@ -478,6 +474,10 @@ ashmem_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 static unsigned long
 ashmem_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
 {
+	/* We might recurse into filesystem code, so bail out if necessary */
+	if (!(sc->gfp_mask & __GFP_FS))
+		sc->will_defer = true;
+
 	/*
 	 * note that lru_count is count of pages on the lru, not a count of
 	 * objects on the list. This means the scan function needs to return the
diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
index e23fb8b7b020..08c95172d0e5 100644
--- a/fs/gfs2/glock.c
+++ b/fs/gfs2/glock.c
@@ -1517,14 +1517,15 @@ static long gfs2_scan_glock_lru(int nr)
 static unsigned long gfs2_glock_shrink_scan(struct shrinker *shrink,
 					    struct shrink_control *sc)
 {
-	if (!(sc->gfp_mask & __GFP_FS))
-		return SHRINK_STOP;
 	return gfs2_scan_glock_lru(sc->nr_to_scan);
 }
 
 static unsigned long gfs2_glock_shrink_count(struct shrinker *shrink,
 					     struct shrink_control *sc)
 {
+	if (!(sc->gfp_mask & __GFP_FS))
+		sc->will_defer = true;
+
 	return vfs_pressure_ratio(atomic_read(&lru_count));
 }
 
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index 69c4b77f127b..d35beda906e8 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -166,9 +166,6 @@ static unsigned long gfs2_qd_shrink_scan(struct shrinker *shrink,
 	LIST_HEAD(dispose);
 	unsigned long freed;
 
-	if (!(sc->gfp_mask & __GFP_FS))
-		return SHRINK_STOP;
-
 	freed = list_lru_shrink_walk(&gfs2_qd_lru, sc,
 				     gfs2_qd_isolate, &dispose);
 
@@ -180,6 +177,9 @@ static unsigned long gfs2_qd_shrink_scan(struct shrinker *shrink,
 static unsigned long gfs2_qd_shrink_count(struct shrinker *shrink,
 					  struct shrink_control *sc)
 {
+	if (!(sc->gfp_mask & __GFP_FS))
+		sc->will_defer = true;
+
 	return vfs_pressure_ratio(list_lru_shrink_count(&gfs2_qd_lru, sc));
 }
 
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 8d501093660f..73735ab1d623 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2202,10 +2202,7 @@ unsigned long
 nfs_access_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 {
 	int nr_to_scan = sc->nr_to_scan;
-	gfp_t gfp_mask = sc->gfp_mask;
 
-	if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
-		return SHRINK_STOP;
 	return nfs_do_access_cache_scan(nr_to_scan);
 }
 
@@ -2213,6 +2210,9 @@ nfs_access_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 unsigned long
 nfs_access_cache_count(struct shrinker *shrink, struct shrink_control *sc)
 {
+	if ((sc->gfp_mask & GFP_KERNEL) != GFP_KERNEL)
+		sc->will_defer = true;
+
 	return vfs_pressure_ratio(atomic_long_read(&nfs_access_nr_entries));
 }
 
diff --git a/fs/super.c b/fs/super.c
index 113c58f19425..66dd2af6cfde 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -73,9 +73,6 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 	 * Deadlock avoidance.  We may hold various FS locks, and we don't want
 	 * to recurse into the FS that called us in clear_inode() and friends..
 	 */
-	if (!(sc->gfp_mask & __GFP_FS))
-		return SHRINK_STOP;
-
 	if (!trylock_super(sb))
 		return SHRINK_STOP;
 
@@ -140,6 +137,9 @@ static unsigned long super_cache_count(struct shrinker *shrink,
 		return 0;
 	smp_rmb();
 
+	if (!(sc->gfp_mask & __GFP_FS))
+		sc->will_defer = true;
+
 	if (sb->s_op && sb->s_op->nr_cached_objects)
 		total_objects = sb->s_op->nr_cached_objects(sb, sc);
 
diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index ca0849043f54..6e0f76532535 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -1680,6 +1680,10 @@ xfs_buftarg_shrink_count(
 {
 	struct xfs_buftarg	*btp = container_of(shrink,
 					struct xfs_buftarg, bt_shrinker);
+
+	if (!(sc->gfp_mask & __GFP_FS))
+		sc->will_defer = true;
+
 	return list_lru_shrink_count(&btp->bt_lru, sc);
 }
 
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index 5e7a37f0cf84..13c842e8f13b 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -502,9 +502,6 @@ xfs_qm_shrink_scan(
 	unsigned long		freed;
 	int			error;
 
-	if ((sc->gfp_mask & (__GFP_FS|__GFP_DIRECT_RECLAIM)) != (__GFP_FS|__GFP_DIRECT_RECLAIM))
-		return 0;
-
 	INIT_LIST_HEAD(&isol.buffers);
 	INIT_LIST_HEAD(&isol.dispose);
 
@@ -534,6 +531,14 @@ xfs_qm_shrink_count(
 	struct xfs_quotainfo	*qi = container_of(shrink,
 					struct xfs_quotainfo, qi_shrinker);
 
+	/*
+	 * __GFP_DIRECT_RECLAIM is used here to avoid blocking kswapd
+	 */
+	if ((sc->gfp_mask & (__GFP_FS|__GFP_DIRECT_RECLAIM)) !=
+					(__GFP_FS|__GFP_DIRECT_RECLAIM)) {
+		sc->will_defer = true;
+	}
+
 	return list_lru_shrink_count(&qi->qi_lru, sc);
 }
 
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index cdb05b48de44..6babcbac4a00 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -527,9 +527,6 @@ static unsigned long
 rpcauth_cache_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 
 {
-	if ((sc->gfp_mask & GFP_KERNEL) != GFP_KERNEL)
-		return SHRINK_STOP;
-
 	/* nothing left, don't come back */
 	if (list_empty(&cred_unused))
 		return SHRINK_STOP;
@@ -541,6 +538,8 @@ static unsigned long
 rpcauth_cache_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
 
 {
+	if ((sc->gfp_mask & GFP_KERNEL) != GFP_KERNEL)
+		sc->will_defer = true;
 	return number_cred_unused * sysctl_vfs_cache_pressure / 100;
 }
 
-- 
2.22.0

