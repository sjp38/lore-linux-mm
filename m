Return-Path: <SRS0=ENxG=UW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11B92C43613
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 10:22:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B368320679
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 10:22:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cqHT+rws"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B368320679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45DE48E0002; Sun, 23 Jun 2019 06:22:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 417EE8E0001; Sun, 23 Jun 2019 06:22:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FEBF8E0002; Sun, 23 Jun 2019 06:22:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id EDDC08E0001
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 06:22:57 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h15so7453640pfn.3
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 03:22:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=z25uKvOtUzpDkL5pdzU9pSdnRSqgdvH++aCD4Aw/SAI=;
        b=DAs2kvfjozPKT9khwhFmQRC+/T6CxvOmWT0kX0tX2eAlZ4B4G1dvYJW3yVxJzrufMl
         3LCYreMKU7P0Bk8fX8jAV3VE/afwegxMQr3kF8IMv+wKvWUVFLpT+8B45miwv2j/MVr1
         HL8ifrcEa02Mcs0wLKNllogUznspDySftAT+/JGNpR2GmqiWZ/a+Ao0hHFaPC60jV7Cs
         R99Si4fpmQ6B8bKfYUc4jcogoc9f9ykFQ9Zlft1XLGOsvsu9+u56j+nPUTxzXEIt8e8y
         X7Nh4tcMJqbwwDdS16UvYVXcPOjQg0ir8IoB9s3SYRSTKQqWBFqfhXZ/KFDPbBdie9u+
         Z6Yg==
X-Gm-Message-State: APjAAAXgqswFLsjuf3yQTK77ebmLpwsaD29j+BlO+/4GPvr9A0zoDmYY
	u1xNjshs0DoKmC52aWj/jnUpIu22f+5+HajwWVu+29mm5hF+K/fMpNum/NSSeDhtDE/0ja9eic8
	UXhNn0sOCBcc33xnS78V75tPVfXCq9uqvq3dpvZ7tQ207lG1VEKqLskn/nKrSu0vuXA==
X-Received: by 2002:a17:902:2862:: with SMTP id e89mr6831332plb.258.1561285377563;
        Sun, 23 Jun 2019 03:22:57 -0700 (PDT)
X-Received: by 2002:a17:902:2862:: with SMTP id e89mr6831284plb.258.1561285376777;
        Sun, 23 Jun 2019 03:22:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561285376; cv=none;
        d=google.com; s=arc-20160816;
        b=uE6anGdZIXyIbAK94q9fZ2Sq+2JPbL664UDKoMOBRNx3NiHhohzPb7S/8JG3ooqd2e
         UO5/g4oWgPtKTqieycGVNyg9lmvwuSEOWNYO6Z43NVVv6gbgLxz5sCXOcNBzNY+PN/Eb
         BsZCUdsEFqDLCkLRgYcYLyX+8hGXU/tds4enxquN2ngfHa+cGA7gVyvSX3cKpasdpt9L
         7dNnkFirOWHdG+QlWuv/v0A11ZfxFp9rd6nnHLLsdtjYq7OdVa5zvvIwPocw2PTcWaU+
         27sHg1nodfZ73SuwCYM3tpm3h5nc4MMKUFJbkeyoBnvAqfxtjN3A15KKivNpTa7VdrUU
         dHhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=z25uKvOtUzpDkL5pdzU9pSdnRSqgdvH++aCD4Aw/SAI=;
        b=edL2alfufr4KYuDh4n5M/XNy+9TVqH4PKI7aDouqExYZupsmAbranErKTK++q4sbJ/
         wzzZcOYDY3E0pN/LWeHfmFWZ51unX2pgQAl4/Yw15FUyhlXY+n8kuOqPwRw73qt7t66L
         6KgUr8Sfs3C4u+mbEW32+bnpI9mm2DsIIZVpnMyosr37y8xlNAo8Srv2zvOgqC01bODa
         CYlg+YsDFLW2TkPrNPr//upgmBFlrAo78AEPQ1e2jS/gsEC+XGalQwUNxNpMHPUsb5dH
         YXmqm33wN8pEKy8cO0/tIzHrQu9IN82pORsp0klFmA94AMSX40I4x8wSx6oZjVhAbfAl
         AIVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cqHT+rws;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d3sor10464745pju.22.2019.06.23.03.22.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 23 Jun 2019 03:22:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cqHT+rws;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=z25uKvOtUzpDkL5pdzU9pSdnRSqgdvH++aCD4Aw/SAI=;
        b=cqHT+rwsq/6yH2O+qkCvj912k4qGoTEeQdF/y92P0wN+/Lo+deTpS9mgKIdArFUpfZ
         ERY/LsqWdXGGg4HsWvaw04KkCSZWgOpnmkpmeoN8xf+3ITOtW9Awk5VDpOmNkKFiW5yD
         wpdOk+Sawq78iRfGkRvzmgwoZKewKgfpE0slFvAeRoeqxGhYsxdX7ocWmdzTzaPYdx5/
         mjCOrOorbfcMnFGmXdeLcxi3mAanwFGIpgyTvCpwUIoStXb/0HECai4GOGwayXNE7AKK
         VkOGl35jgMuxjr2VKolmdNwHBMFwRnkUcjQoNicFPEvy/y6bvmIny/3LfKtgWAqpBVlS
         AxUA==
X-Google-Smtp-Source: APXvYqwuIP5kdieNeV6Vhyz1zsfUAJXD2eC89maMqyiCY0Od5RDYWcfmPONacQTmNGQhJlVb+YV0dg==
X-Received: by 2002:a17:90a:8984:: with SMTP id v4mr17897849pjn.133.1561285376459;
        Sun, 23 Jun 2019 03:22:56 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id r4sm6924539pjd.25.2019.06.23.03.22.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jun 2019 03:22:55 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org,
	mhocko@suse.com
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm/vmscan: expose cgroup_ino for shrink slab tracepoints
Date: Sun, 23 Jun 2019 18:22:33 +0800
Message-Id: <1561285353-3986-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There may be many containers deployed on one host. But we only
want to trace the slab caches in a speficed container sometimes.
The exposed cgroup_ino in mm_shrink_slab_{start, end} tracepoints can
help us.

It can be used as bellow,
step 1, get the inode of the specified cgroup
	$ ls -di /tmp/cgroupv2/foo
step 2, set this inode into tracepoint filter to trace this cgroup only
	(assume the inode is 11)
	$ cd /sys/kernel/debug/tracing/events/vmscan/
	$ echo 'cgroup_ino == 11' > mm_shrink_slab_start/filter
	$ echo 'cgroup_ino == 11' > mm_shrink_slab_end/filter

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 include/trace/events/vmscan.h | 23 +++++++++++++++--------
 mm/vmscan.c                   |  3 ++-
 2 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index c37e228..4f80fa3 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -248,6 +248,7 @@
 		__field(unsigned long long, delta)
 		__field(unsigned long, total_scan)
 		__field(int, priority)
+		__field(unsigned int, cgroup_ino)
 	),
 
 	TP_fast_assign(
@@ -260,9 +261,10 @@
 		__entry->delta = delta;
 		__entry->total_scan = total_scan;
 		__entry->priority = priority;
+		__entry->cgroup_ino = cgroup_ino(sc->memcg->css.cgroup);
 	),
 
-	TP_printk("%pS %p: nid: %d objects to shrink %ld gfp_flags %s cache items %ld delta %lld total_scan %ld priority %d",
+	TP_printk("%pS %p: nid: %d objects to shrink %ld gfp_flags %s cache items %ld delta %lld total_scan %ld priority %d cgroup_ino %u",
 		__entry->shrink,
 		__entry->shr,
 		__entry->nid,
@@ -271,14 +273,16 @@
 		__entry->cache_items,
 		__entry->delta,
 		__entry->total_scan,
-		__entry->priority)
+		__entry->priority,
+		__entry->cgroup_ino)
 );
 
 TRACE_EVENT(mm_shrink_slab_end,
-	TP_PROTO(struct shrinker *shr, int nid, int shrinker_retval,
-		long unused_scan_cnt, long new_scan_cnt, long total_scan),
+	TP_PROTO(struct shrinker *shr, struct shrink_control *sc,
+		int shrinker_retval, long unused_scan_cnt,
+		long new_scan_cnt, long total_scan),
 
-	TP_ARGS(shr, nid, shrinker_retval, unused_scan_cnt, new_scan_cnt,
+	TP_ARGS(shr, sc, shrinker_retval, unused_scan_cnt, new_scan_cnt,
 		total_scan),
 
 	TP_STRUCT__entry(
@@ -289,26 +293,29 @@
 		__field(long, new_scan)
 		__field(int, retval)
 		__field(long, total_scan)
+		__field(unsigned int, cgroup_ino)
 	),
 
 	TP_fast_assign(
 		__entry->shr = shr;
-		__entry->nid = nid;
+		__entry->nid = sc->nid;
 		__entry->shrink = shr->scan_objects;
 		__entry->unused_scan = unused_scan_cnt;
 		__entry->new_scan = new_scan_cnt;
 		__entry->retval = shrinker_retval;
 		__entry->total_scan = total_scan;
+		__entry->cgroup_ino = cgroup_ino(sc->memcg->css.cgroup);
 	),
 
-	TP_printk("%pS %p: nid: %d unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
+	TP_printk("%pS %p: nid: %d unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d cgroup_ino %u",
 		__entry->shrink,
 		__entry->shr,
 		__entry->nid,
 		__entry->unused_scan,
 		__entry->new_scan,
 		__entry->total_scan,
-		__entry->retval)
+		__entry->retval,
+		__entry->cgroup_ino)
 );
 
 TRACE_EVENT(mm_vmscan_lru_isolate,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d6c3fc8..a9a03a4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -578,7 +578,8 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	else
 		new_nr = atomic_long_read(&shrinker->nr_deferred[nid]);
 
-	trace_mm_shrink_slab_end(shrinker, nid, freed, nr, new_nr, total_scan);
+	trace_mm_shrink_slab_end(shrinker, shrinkctl, freed, nr, new_nr,
+				 total_scan);
 	return freed;
 }
 
-- 
1.8.3.1

