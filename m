Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABCBAC282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 19:36:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 738582171F
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 19:36:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 738582171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EEF2E8E0002; Mon, 28 Jan 2019 14:36:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E9EF38E0001; Mon, 28 Jan 2019 14:36:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB4E68E0002; Mon, 28 Jan 2019 14:36:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id B39D08E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 14:36:14 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id n45so21908301qta.5
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 11:36:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-transfer-encoding:sender;
        bh=QE+fDjOW2/2KHYiahIYiRMMiB4vV7w3SM+TfLqvRjGY=;
        b=ttPIzr279Ie1LYs2jJv2EdStalOe4FKxolHoZOA0bIQD8c5P9PkksxKnxEfF0nf+n2
         d+wkCK6HchT3GU63+oEMJp+JT6AGYzS+k7GF1Y1I9X03xL5xVGlKHacMgYXxf5yWybQn
         atPqGSRFGokRgYdrHrVXCAzp9+9iTwUGFRfSJHu7CCFrp5Ms3IeUz2td5noE8uibuTHJ
         Pg3ixcse0ly85vr6X9ANxPp/RBP4ftlZTiWf8eIoH33ynuLJQPGcAREHzFOdy1mh3Clg
         F0RwviXdBUFcuAWT2jCsE5EYpbRmzxQp7mRfajATsqC9Cii444SItPpTaii3U50p987i
         ruLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: AJcUukcjwcPw+ipxaP0Q5AWyI0XlgGKj/ioJ+fPuOeTCyQO56gZnZ1Bq
	ad5a50HBr/AqKsCZTSqkjTXyxlUWAhliJoDD7WtFFQUP1ogTNougsfzwXGClzkvYV9cSeNXC41j
	kwz0Q3eGWMIiT72QP3Fq8zf5G9gSoo8l/nOhYNNaPrjPL8CaBUL33p6i4SZmOUaOTXQ==
X-Received: by 2002:a37:9906:: with SMTP id b6mr20741174qke.208.1548704174486;
        Mon, 28 Jan 2019 11:36:14 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6XCgqde3BMMaz3EzH5aTotyfFOA2Y+7xiuMFJRuoP7vBFcKwwZEMb+FlB2nF+O+yZ7YtOa
X-Received: by 2002:a37:9906:: with SMTP id b6mr20741129qke.208.1548704173692;
        Mon, 28 Jan 2019 11:36:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548704173; cv=none;
        d=google.com; s=arc-20160816;
        b=dBih2zQ7ReQLBG9DCmSdKady6+7eUperewvdN9DHTNu46R41dOQXrX8xmNbnXwsuN2
         s2nZpPOpyltXSEfA+2Pstzmq1E0sgYSorRcS/8MbIjIBoSSm52hQ3veVAwivMCa72Tug
         tEL+7fImuGP7sCEJTD3QRMdosjjP5gWtzRzE2w5ZoujAPU/f5rNe60Hz0RWNk2ho+wrT
         exUNJQAX3/ak776s2UHAu9lk9HGGuMChVsD2qb3hAnfzsNenGEZsjwkPEPdUjntykR6m
         0wAJ5ScfyKm63v5fghHL4GbTkNuNvBjzEEBrcx4WXFSNAJN1k7OTD5OCvO0ZQ67ego1u
         mgLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:content-transfer-encoding:mime-version:message-id:subject:cc
         :to:from:date;
        bh=QE+fDjOW2/2KHYiahIYiRMMiB4vV7w3SM+TfLqvRjGY=;
        b=R5jYFkPZJW5DGMuee1Ut8qKkkU7Fin6do2mxP/qaDv7TJaC3o7bMkTAPjo/ZPyIaKm
         JvNCpLQ023lTB8gPRgBKHh53pqmzgkfyTnt84XWOwrWi9aHnAUMYNgsqDM+F8Ejxic6j
         7B9LqpzXYlQR2tKmkboR3/exnDnitofAhkApF4H2h5Pu+sw6zeZVBB94q1N1bkdqkgah
         EpUmbTdV9rpmzRVf3TNpfGBlScLlWQ2aQijLAH24h32nvi4b8nv51gJnVgaacidi43u9
         86UwpScVQ1bfvZqwzKTMJtVtN10gRxlanGmw9k35GTL5jJxVFCLxsEf6KPtv9GoA2ije
         ky1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id n64si1265649qkd.12.2019.01.28.11.36.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 11:36:12 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from [2001:470:1f07:12aa:6e0b:84ff:fee2:98bb] (helo=imladris.surriel.com)
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.91)
	(envelope-from <riel@shelob.surriel.com>)
	id 1goChS-0006oM-NH; Mon, 28 Jan 2019 14:36:06 -0500
Date: Mon, 28 Jan 2019 14:35:35 -0500
From: Rik van Riel <riel@surriel.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-team@fb.com, Johannes Weiner
 <hannes@cmpxchg.org>, Chris Mason <clm@fb.com>, Roman Gushchin
 <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko
 <mhocko@suse.com>
Subject: [PATCH] mm,slab,vmscan: accumulate gradual pressure on small slabs
Message-ID: <20190128143535.7767c397@imladris.surriel.com>
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; x86_64-redhat-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There are a few issues with the way the number of slab objects to
scan is calculated in do_shrink_slab.  First, for zero-seek slabs,
we could leave the last object around forever. That could result
in pinning a dying cgroup into memory, instead of reclaiming it.
The fix for that is trivial.

Secondly, small slabs receive much more pressure, relative to their
size, than larger slabs, due to "rounding up" the minimum number of
scanned objects to batch_size.

We can keep the pressure on all slabs equal relative to their size
by accumulating the scan pressure on small slabs over time, resulting
in sometimes scanning an object, instead of always scanning several.

This results in lower system CPU use, and a lower major fault rate,
as actively used entries from smaller caches get reclaimed less
aggressively, and need to be reloaded/recreated less often.

Fixes: 4b85afbdacd2 ("mm: zero-seek shrinkers")
Fixes: 172b06c32b94 ("mm: slowly shrink slabs with a relatively small number of objects")
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Chris Mason <clm@fb.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: kernel-team@fb.com
Tested-by: Chris Mason <clm@fb.com>
---
 include/linux/shrinker.h |  1 +
 mm/vmscan.c              | 16 +++++++++++++---
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 9443cafd1969..7a9a1a0f935c 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -65,6 +65,7 @@ struct shrinker {
 
 	long batch;	/* reclaim batch size, 0 = default */
 	int seeks;	/* seeks to recreate an obj */
+	int small_scan;	/* accumulate pressure on slabs with few objects */
 	unsigned flags;
 
 	/* These are for internal use */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a714c4f800e9..0e375bd7a8b6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -488,18 +488,28 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 		 * them aggressively under memory pressure to keep
 		 * them from causing refetches in the IO caches.
 		 */
-		delta = freeable / 2;
+		delta = (freeable + 1)/ 2;
 	}
 
 	/*
 	 * Make sure we apply some minimal pressure on default priority
-	 * even on small cgroups. Stale objects are not only consuming memory
+	 * even on small cgroups, by accumulating pressure across multiple
+	 * slab shrinker runs. Stale objects are not only consuming memory
 	 * by themselves, but can also hold a reference to a dying cgroup,
 	 * preventing it from being reclaimed. A dying cgroup with all
 	 * corresponding structures like per-cpu stats and kmem caches
 	 * can be really big, so it may lead to a significant waste of memory.
 	 */
-	delta = max_t(unsigned long long, delta, min(freeable, batch_size));
+	if (!delta) {
+		shrinker->small_scan += freeable;
+
+		delta = shrinker->small_scan >> priority;
+		shrinker->small_scan -= delta << priority;
+
+		delta *= 4;
+		do_div(delta, shrinker->seeks);
+
+	}
 
 	total_scan += delta;
 	if (total_scan < 0) {

