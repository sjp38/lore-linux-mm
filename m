Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D948FC169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 05:37:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 829D92086C
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 05:37:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 829D92086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10CD68E007A; Fri,  8 Feb 2019 00:37:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 094868E0079; Fri,  8 Feb 2019 00:37:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9F1E8E007A; Fri,  8 Feb 2019 00:37:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A415A8E0079
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 00:37:31 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id o187so1608472pgo.2
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 21:37:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bFjOGnF+pZkR+DeKYwsVwatycoayMcbcJOpIKZgNxb4=;
        b=Rja+1AVbmIUWUl6aR69bwkmqez/f9rxz9xmx6OlhGgyNqMGIjnDp5NOV94sKvaemG/
         ZNfh8+DwKV5zDFy+sd88HwEmw5Mf4yTLEyQomlGbQH75an5vVRsO3W8YY84Yba/v9J6E
         BJkm3ZAGgawQ/zbzmVDu/nnTFRdMt0rKMub6SSCRCEBfePRr06sU3OVsRfazFgQzVQ1S
         OpK/uzcA3Q5/JsJ9zhwiO3sYCYnKWqAcZB/MTorZmV4pDTZJTpBcHCwyyTejUPjPyRfx
         IGYZl0fF8B22dO5envBfATRSqpnWIzIRmCxB3qZXZQpyJzqoD/KonAkfIqb6xk+Qu52H
         LNIg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuYz1JoYdKTAdo9/oB+aHgeDy2/HRggBuho2ysNrJZ9AB1nR+XZI
	MSYhWOY2YAtRbVl8BZRXPVbqezmNfO8QJvV6VzfTxrovKapRTq2szy+TT0IvFGF3+bzXQpCskVL
	WogWuinWGOgN4QNuzG4FHOrKO71AzVwlFX89ScJZQ+SWzYKyzg1jkTojOgUOA4hRQ2Q==
X-Received: by 2002:a62:ca48:: with SMTP id n69mr14116805pfg.162.1549604251302;
        Thu, 07 Feb 2019 21:37:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IafnZVvpc6VjtC4O6ZsHYspVz/Ltu51JQTuK86FmT3fggadi3hzl+XgVSgSDWram5C4+ZXB
X-Received: by 2002:a62:ca48:: with SMTP id n69mr14116749pfg.162.1549604250380;
        Thu, 07 Feb 2019 21:37:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549604250; cv=none;
        d=google.com; s=arc-20160816;
        b=FM+MXiJdsmt22D03QdGVhbNZoTqYPhruz/RB6NwkYoSlU4r4j1P8EmHKc0olLO368H
         tx9DQ9I/H2yaSF+LcCJbOTsKQ7tNxvQFSTfj1IPoi5qddCTJwn9VOf5eRCUutclzUSoU
         Pthbqa5cpl5NCpSpKK0sfTWwhh5VB4eq+IQrLPUZtIetq1Hdk0Vdq7xNTKuyRCU3q+7s
         427iq2ggNly1e5hfL8bmRL1fs+7ZQIxV0S1rmOVzcUm2b/DcRDfskSI6LluhgFKs8N+U
         lmaJcjZHEs0BMH8Ok1F5bY85cHXnz2n0cLE9Et7j2WnvuA9j73N4bmjw/ExgblCC8AfM
         kXQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=bFjOGnF+pZkR+DeKYwsVwatycoayMcbcJOpIKZgNxb4=;
        b=ONykeTiVwY3WR7JGagRuGp8pOlARqapXIbrS6bMvtP6yzgn8szc0M3IAAtrSoRESld
         EvrXBw2fi7N0sDra4oHq95OhWZdYx3WyrCVbAW+okbWIZ8PzOwfVvJJ0viphvibTXfyT
         qGX4BUu+nif+al8WEojcqkqkq2ZgIRqZ08YKu6lKWbfeLYXSAAjDrQ3X4tMs0Wx0eUOG
         ZmJCb9SKkhA79gGtCt89arzk0/Q8P39G5Fpc2g38QD+RJ6Xmh4Etf+BcEndNCWEGHQ9e
         WVpgcjdMSdrdLn67iRtCVqLLaR7poduBExbBaEvC5KH2+HDFeaab07on1i0aVWZ0vTBx
         qOYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e15si1285117pgg.281.2019.02.07.21.37.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 21:37:30 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 73A48BF6A;
	Fri,  8 Feb 2019 05:37:29 +0000 (UTC)
Date: Thu, 7 Feb 2019 21:37:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Jan Kara <jack@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Roman Gushchin <guro@fb.com>, Michal
 Hocko <mhocko@kernel.org>, Chris Mason <clm@fb.com>, "linux-mm@kvack.org"
 <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org"
 <linux-fsdevel@vger.kernel.org>, "linux-xfs@vger.kernel.org"
 <linux-xfs@vger.kernel.org>, "vdavydov.dev@gmail.com"
 <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 1/2] Revert
 "mm: don't reclaim inodes with many attached pages"
Message-Id: <20190207213727.a791db810341cec2c013ba93@linux-foundation.org>
In-Reply-To: <20190207102750.GA4570@quack2.suse.cz>
References: <20190130041707.27750-1-david@fromorbit.com>
	<20190130041707.27750-2-david@fromorbit.com>
	<25EAF93D-BC63-4409-AF21-F45B2DDF5D66@fb.com>
	<20190131013403.GI4205@dastard>
	<20190131091011.GP18811@dhcp22.suse.cz>
	<20190131185704.GA8755@castle.DHCP.thefacebook.com>
	<20190131221904.GL4205@dastard>
	<20190207102750.GA4570@quack2.suse.cz>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Feb 2019 11:27:50 +0100 Jan Kara <jack@suse.cz> wrote:

> On Fri 01-02-19 09:19:04, Dave Chinner wrote:
> > Maybe for memcgs, but that's exactly the oppose of what we want to
> > do for global caches (e.g. filesystem metadata caches). We need to
> > make sure that a single, heavily pressured cache doesn't evict small
> > caches that lower pressure but are equally important for
> > performance.
> > 
> > e.g. I've noticed recently a significant increase in RMW cycles in
> > XFS inode cache writeback during various benchmarks. It hasn't
> > affected performance because the machine has IO and CPU to burn, but
> > on slower machines and storage, it will have a major impact.
> 
> Just as a data point, our performance testing infrastructure has bisected
> down to the commits discussed in this thread as the cause of about 40%
> regression in XFS file delete performance in bonnie++ benchmark.
> 

Has anyone done significant testing with Rik's maybe-fix?



From: Rik van Riel <riel@surriel.com>
Subject: mm, slab, vmscan: accumulate gradual pressure on small slabs

There are a few issues with the way the number of slab objects to scan is
calculated in do_shrink_slab.  First, for zero-seek slabs, we could leave
the last object around forever.  That could result in pinning a dying
cgroup into memory, instead of reclaiming it.  The fix for that is
trivial.

Secondly, small slabs receive much more pressure, relative to their size,
than larger slabs, due to "rounding up" the minimum number of scanned
objects to batch_size.

We can keep the pressure on all slabs equal relative to their size by
accumulating the scan pressure on small slabs over time, resulting in
sometimes scanning an object, instead of always scanning several.

This results in lower system CPU use, and a lower major fault rate, as
actively used entries from smaller caches get reclaimed less aggressively,
and need to be reloaded/recreated less often.

[akpm@linux-foundation.org: whitespace fixes, per Roman]
[riel@surriel.com: couple of fixes]
  Link: http://lkml.kernel.org/r/20190129142831.6a373403@imladris.surriel.com
Link: http://lkml.kernel.org/r/20190128143535.7767c397@imladris.surriel.com
Fixes: 4b85afbdacd2 ("mm: zero-seek shrinkers")
Fixes: 172b06c32b94 ("mm: slowly shrink slabs with a relatively small number of objects")
Signed-off-by: Rik van Riel <riel@surriel.com>
Tested-by: Chris Mason <clm@fb.com>
Acked-by: Roman Gushchin <guro@fb.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Jonathan Lemon <bsd@fb.com>
Cc: Jan Kara <jack@suse.cz>
Cc: <stable@vger.kernel.org>

Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---


--- a/include/linux/shrinker.h~mmslabvmscan-accumulate-gradual-pressure-on-small-slabs
+++ a/include/linux/shrinker.h
@@ -65,6 +65,7 @@ struct shrinker {
 
 	long batch;	/* reclaim batch size, 0 = default */
 	int seeks;	/* seeks to recreate an obj */
+	int small_scan;	/* accumulate pressure on slabs with few objects */
 	unsigned flags;
 
 	/* These are for internal use */
--- a/mm/vmscan.c~mmslabvmscan-accumulate-gradual-pressure-on-small-slabs
+++ a/mm/vmscan.c
@@ -488,18 +488,30 @@ static unsigned long do_shrink_slab(stru
 		 * them aggressively under memory pressure to keep
 		 * them from causing refetches in the IO caches.
 		 */
-		delta = freeable / 2;
+		delta = (freeable + 1) / 2;
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
+	if (!delta && shrinker->seeks) {
+		unsigned long nr_considered;
+
+		shrinker->small_scan += freeable;
+		nr_considered = shrinker->small_scan >> priority;
+
+		delta = 4 * nr_considered;
+		do_div(delta, shrinker->seeks);
+
+		if (delta)
+			shrinker->small_scan -= nr_considered << priority;
+	}
 
 	total_scan += delta;
 	if (total_scan < 0) {
_

