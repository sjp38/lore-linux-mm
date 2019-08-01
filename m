Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED00AC32755
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD018216C8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD018216C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 270B08E000E; Wed, 31 Jul 2019 22:18:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC29C8E0010; Wed, 31 Jul 2019 22:18:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2E0B8E0003; Wed, 31 Jul 2019 22:18:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 612FB8E000E
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:18:11 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 191so44592602pfy.20
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:18:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6Ypp4aA3f8kQSGxsw8XISBG/OEfUW8QH41P+GPRTyvE=;
        b=M94N1/1qlXdMf+V7vtkiZwjgrNKrcydkAtKfHGyD/LP6ykjmBpzTr/eihotNb31wqx
         iqWrOqARyaavmiSJtS2P3nM8olReqEIiO/DhStxpFd7mCG124oFxDh3CxUrYEESXmnUg
         XFFEeDOCTc92S0xA4BoafAUjJa25vG+0VSX9a0PsasGyZTQyqVf3D1m7p4vtKlzqhw6c
         /B5JLCe/j35L8pplHszT8DgrpQ7wUjTRb4HMSAKRhvjbep01x9H8NDRoqdzfYpLPVR5M
         wkZTZ3QtErDBDytI+/8PVF2vRowTQbd0wVqF94ywtwq4uhBc7CkmRukhXwFMe+DeMqKj
         Ctng==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXyeR7KIzOdW2qtaL8RhQVeiWBtOh+Z+5FHWSOBE8mkmW13/HS5
	wWqJiJ1QGXKY4EQXEsO3b/Nl7HcKQ8Jfq4QGHv615qWoG0zxizo3aZPZPpHTI28K1rajiE90A+7
	M8uLvl75JO2Fh7SgPIf+cTfPxUAooyp9GmNRPJeweTztUOElMVj2cSH9KRDugcKA=
X-Received: by 2002:a17:90a:8d86:: with SMTP id d6mr5891412pjo.94.1564625891061;
        Wed, 31 Jul 2019 19:18:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxl0Q0INw28ahWjXT5HbIEAT3G1qlmW4V9AhOyZCNmyXmoo8HMsScjR5HCDA15qkgn9jiGO
X-Received: by 2002:a17:90a:8d86:: with SMTP id d6mr5890893pjo.94.1564625881679;
        Wed, 31 Jul 2019 19:18:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564625881; cv=none;
        d=google.com; s=arc-20160816;
        b=aY+Yn6TV30finFNb/ELdSWswBO6WZp2jWnGUY5C7+J5n5NhNFeJMRCAkBEQWzwOks1
         PcK9R84vmedpIb/WbpvjpIk+7rIcS0J4bxn7nPnkitCw7YYYo6SPwg7eJ5uC0FcqxYYr
         O9SFlWAFGx92SE+Y+429DUWgYDCXB3gsK0jpJkyEwvc3TDYdoD9/IadVkrdtccql3sCD
         0Q3rZ71VmXhDI27XG6qqdHPdbr+Low0SIiuDvy1adBCBhd5hb6wp+rto1vRvfMKOnyPo
         R7edogSPcxhKBp27QZPE0Lh0zG+e2nVsEw5GYJ/76qnhhaBSppNw3nr57raMhOglrVpW
         Rn2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=6Ypp4aA3f8kQSGxsw8XISBG/OEfUW8QH41P+GPRTyvE=;
        b=E8Etq5MW1erquQlxMIVOjAlCgx6vPyn/1Jj57NsIDvegc9xfZuP7hDrx5CtphDPdiO
         R7AXj1z29jrVHwuMIen1VetoMk2WpvowJh6pSQDlNvh9FR4ZfvCeoXl9eIVIZ9bbd6Ti
         70bqx12aRt+QCYv/vfdfYt2oakRgl83u756L2q8cYGDMWkBImaQ8LuwUJqxLbS+Vvfdo
         rR/9fNTbEnhsY13HohpkrRewPh8rbAZxssmSH28hnzG8G6+2PDQm2xLAWiUXiz4BYX1r
         jI7DLtZR6NQ1BgyaRMye4C/+ppBbpRSsAbry/+puIllmmcpF+gY/u2FkgB/n9saTBA7y
         E8Cg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id k143si33125871pfd.212.2019.07.31.19.18.01
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 19:18:01 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id A2FD143EBEB;
	Thu,  1 Aug 2019 12:17:58 +1000 (AEST)
Received: from discord.disaster.area ([192.168.253.110])
	by dread.disaster.area with esmtp (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0eA-0003aj-Up; Thu, 01 Aug 2019 12:16:50 +1000
Received: from dave by discord.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0fG-0001ku-Su; Thu, 01 Aug 2019 12:17:58 +1000
From: Dave Chinner <david@fromorbit.com>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH 08/24] mm: kswapd backoff for shrinkers
Date: Thu,  1 Aug 2019 12:17:36 +1000
Message-Id: <20190801021752.4986-9-david@fromorbit.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801021752.4986-1-david@fromorbit.com>
References: <20190801021752.4986-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=FmdZ9Uzk2mMA:10 a=20KFwNOVAAAA:8
	a=NNMOctoXzqbiiAOzY8AA:9
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

When kswapd reaches the end of the page LRU and starts hitting dirty
pages, the logic in shrink_node() allows it to back off and wait for
IO to complete, thereby preventing kswapd from scanning excessively
and driving the system into swap thrashing and OOM conditions.

When we have inode cache heavy workloads on XFS, we have exactly the
same problem with reclaim inodes. The non-blocking kswapd reclaim
will keep putting pressure onto the inode cache which is unable to
make progress. When the system gets to the point where there is no
pages in the LRU to free, there is no swap left and there are no
clean inodes that can be freed, it will OOM. This has a specific
signature in OOM:

[  110.841987] Mem-Info:
[  110.842816] active_anon:241 inactive_anon:82 isolated_anon:1
                active_file:168 inactive_file:143 isolated_file:0
                unevictable:2621523 dirty:1 writeback:8 unstable:0
                slab_reclaimable:564445 slab_unreclaimable:420046
                mapped:1042 shmem:11 pagetables:6509 bounce:0
                free:77626 free_pcp:2 free_cma:0

In this case, we have about 500-600 pages left in teh LRUs, but we
have ~565000 reclaimable slab pages still available for reclaim.
Unfortunately, they are mostly dirty inodes, and so we really need
to be able to throttle kswapd when shrinker progress is limited due
to reaching the dirty end of the LRU...

So, add a flag into the reclaim_state so if the shrinker decides it
needs kswapd to back off and wait for a while (for whatever reason)
it can do so.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 include/linux/swap.h |  1 +
 mm/vmscan.c          | 10 +++++++++-
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 1a3502a9bc1f..416680b1bf0c 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -133,6 +133,7 @@ struct reclaim_state {
 	unsigned long	reclaimed_pages;	/* pages freed by shrinkers */
 	unsigned long	scanned_objects;	/* quantity of work done */ 
 	unsigned long	deferred_objects;	/* work that wasn't done */
+	bool		need_backoff;		/* tell kswapd to slow down */
 };
 
 #ifdef __KERNEL__
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4dc8e333f2c6..029dba76ee5a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2844,8 +2844,16 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			 * implies that pages are cycling through the LRU
 			 * faster than they are written so also forcibly stall.
 			 */
-			if (sc->nr.immediate)
+			if (sc->nr.immediate) {
 				congestion_wait(BLK_RW_ASYNC, HZ/10);
+			} else if (reclaim_state && reclaim_state->need_backoff) {
+				/*
+				 * Ditto, but it's a slab cache that is cycling
+				 * through the LRU faster than they are written
+				 */
+				congestion_wait(BLK_RW_ASYNC, HZ/10);
+				reclaim_state->need_backoff = false;
+			}
 		}
 
 		/*
-- 
2.22.0

