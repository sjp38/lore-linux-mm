Return-Path: <SRS0=s2+Z=O6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73D3CC43387
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 17:02:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EC8C21903
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 17:02:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ixLvnwMe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EC8C21903
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F7808E0002; Fri, 21 Dec 2018 12:02:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A4F78E0001; Fri, 21 Dec 2018 12:02:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 846D68E0002; Fri, 21 Dec 2018 12:02:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3EE538E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 12:02:40 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 82so5446100pfs.20
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 09:02:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=mc/kXC3WRRrlQez9w8XSEK+8/bbcJDPSNq4STwLZVy4=;
        b=OTN4gmwxLJoSX9cqWBNkPYpNkKIfvNeQKtx0bEJGMvIiCi7m/lPx3dy78J9rpED6sA
         5rUbJVfihDw3Jd/ZyEbkpe3dW35PvHGccy7hjlUVvom284KY0AbWpv/TByJjhjwdT0B2
         UFuee9NrrTXe1BIefVPKuAHUxNZo2bawamuSVqACqORaoWfqUplWsx0rRdxXS4OPdHxy
         kz1auAUQYA7g/F4ces453wQOVkCW4FggeyAHXsVbCwHDKBkSRkKIp4BdMKvPa8CUyE+1
         vUiH5bCkZWj0fIASALHd3CxOGUnkcyYzDARLFmepgEBY5eOxAGX9zRpq8PZLI3uMlREs
         nQyQ==
X-Gm-Message-State: AJcUukc35g9TrroEpgm+UIxqYMcNOStLKLwFG7j+lXes4lzYISpTw9RT
	W0PhfA7iYQN3b4+nS/aF+CtFXVvrdXCIvzmxc2gKBnxRObxzjyH1BDI36DD6HxDIGPCdaHOToS1
	laxrJzprwlDV9ZyefkncoZOFWCUHyfPfoBReyyDqhMEk/cG3IKcEI3gGb9Nq4BxcIQyUtiZ8lZQ
	9GPtiH61+aEx6PivXfxxOBVqD/U9CkiYeQv32IX3IFWDuW2DTnuE1vRDfk9T5TrvoZsrBhRa2vM
	YpMt12R0ZGNGyGOz5NO+rI95sQ7bTfPxwY3bVvRMRXBHkoFCKMDlJ7Z7y4fuZzhBrbEGs6Btue+
	oo/x6U4wD4NNj3Kz2wU6uY5cxPshwOJAnmrR7emgSadPTzUWd8XFbVK2VuYXx+RJOAEspGwgOqs
	U
X-Received: by 2002:a65:62da:: with SMTP id m26mr3179473pgv.278.1545411759864;
        Fri, 21 Dec 2018 09:02:39 -0800 (PST)
X-Received: by 2002:a65:62da:: with SMTP id m26mr3179403pgv.278.1545411758946;
        Fri, 21 Dec 2018 09:02:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545411758; cv=none;
        d=google.com; s=arc-20160816;
        b=Num/GisnQKpkIT0CRl7A1+xzwxBR4Nn528bzoSpLLaP9mrlqf5NH6aaVs9p18BbjVQ
         B5OtHcSCUzdcfxW3B8a0RG/G545FU/6uEt/rP0qOrCfltuEGdQP3TjotY+sYg1VSFsiH
         cZKaaFofAhSbnAmqcTtxA3KgUJu2S/HtPoeo5xZSLf5keTFyi5O+giiMzGYtQN1lIiGT
         PVmYYB/BFV9xtQOUM9Qgp+2EMpp5aIIOCfi6ZIDU4zflfTCeP/0CUWvKqjZqLS3apXxT
         yhkMM22lPKOMWi/hc9plMm2/AM8qGEGqpHqlPucI6N9DHbzL2/uE4RBZhqak5CRK8eXh
         oKmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=mc/kXC3WRRrlQez9w8XSEK+8/bbcJDPSNq4STwLZVy4=;
        b=mWtUOOPv5PW30Uod37+4xGUPSR/xKCV0lKBj+q4/cPY+DapOa8/qxHj/wnb+ynV05n
         Fw4vEm1waJberZtMYeOBQqF/bfJ/lfNTROSTtybzNgn8UZwYAmX6lqF8M538GiX/fd+5
         CkGcsmmETtnpU3K3MMuqA741jMEb53Jw5z9mF3R83Dfc/Dqux0UoJeywens17KWCcxiw
         HBPzuJS1/ZLRIIpWzB+FXWb5WmEPKb3nelSgUthTC6pl1zOLwsMmnQwIm72Ed+BunEU0
         UUdHtF6DbPAWgsABLpJiu5tGtEMJ2mdyHUTlN6vCghlTgALzMf6a5g6Oq4aA+kglzBnn
         +naw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ixLvnwMe;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i5sor40224028pgq.34.2018.12.21.09.02.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 09:02:38 -0800 (PST)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ixLvnwMe;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=mc/kXC3WRRrlQez9w8XSEK+8/bbcJDPSNq4STwLZVy4=;
        b=ixLvnwMepCoxUzowoeYkTnb/fyKE97LPVkL9QVjRhPppWDeJ2N9PfWpUK1HcnN5Jlr
         M1o1PjujssYpk6irxtt1/qg73e9AXmupzHaiJaJcXxsojRn+IdkstlYMlvDOKbfPC7Nb
         SeIgzeQt3Pw9qc1MmSVgcVoqL2pMGOBoFUOIgp+X8YgYs2B9o1Q3EDSyZNNccNBHLiru
         UKYz+1RKcnPne6XjJ+4xTptkVSfx7vs7T/EtnOM4LGi1xfjS2mXPGMN3lkqM3GGY3nti
         /JnZjXSXtzvH1NBCHsg8kHhj5GtjW1RKn1motds08HNN9cXSVCYdRLsKoGZdPDmRGVFC
         t3KA==
X-Google-Smtp-Source: ALg8bN6d1ebv1+aT4u75oxMoeiFLYhhaEuNGbDuejEDYpt4GMpg2cujsrOwk+Y0jJC3nXLP4/4SU2w==
X-Received: by 2002:a65:484c:: with SMTP id i12mr3111226pgs.309.1545411758217;
        Fri, 21 Dec 2018 09:02:38 -0800 (PST)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id i72sm35034995pfe.181.2018.12.21.09.02.36
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 09:02:37 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org,
	mhocko@suse.com,
	osalvador@suse.de,
	david@redhat.com,
	Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH v3] mm: remove extra drain pages on pcp list
Date: Sat, 22 Dec 2018 01:02:28 +0800
Message-Id: <20181221170228.10686-1-richard.weiyang@gmail.com>
X-Mailer: git-send-email 2.15.1
In-Reply-To: <20181218204656.4297-1-richard.weiyang@gmail.com>
References: <20181218204656.4297-1-richard.weiyang@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20181221170228.QJeysUN1ksX1Bl-q0P7FkLSzWgnct93nAZo5j8mcT2g@z>

In current implementation, there are two places to isolate a range of
page: __offline_pages() and alloc_contig_range(). During this procedure,
it will drain pages on pcp list.

Below is a brief call flow:

  __offline_pages()/alloc_contig_range()
      start_isolate_page_range()
          set_migratetype_isolate()
              drain_all_pages()
      drain_all_pages()                 <--- A

From this snippet we can see current logic is isolate and drain pcp list
for each pageblock and drain pcp list again for the whole range.

While the drain at A is not necessary. The reason is
start_isolate_page_range() will set the migrate type of a range to
MIGRATE_ISOLATE. After doing so, this range will never be allocated from
Buddy, neither to a real user nor to pcp list. This means the procedure
to drain pages on pcp list after start_isolate_page_range() will not
drain any page in the target range.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

---
v3:
  * it is not proper to rely on caller to drain pages, so keep to drain
    pages during iteration and remove the one in callers.
v2: adjust changelog with MIGRATE_ISOLATE effects for the isolated range
---
 mm/memory_hotplug.c | 1 -
 mm/page_alloc.c     | 1 -
 2 files changed, 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6910e0eea074..d2fa6cbbb2db 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1599,7 +1599,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
 
 	cond_resched();
 	lru_add_drain_all();
-	drain_all_pages(zone);
 
 	pfn = scan_movable_pages(start_pfn, end_pfn);
 	if (pfn) { /* We have movable pages */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f1edd36a1e2b..d9ee4bb3a1a7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8041,7 +8041,6 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	 */
 
 	lru_add_drain_all();
-	drain_all_pages(cc.zone);
 
 	order = 0;
 	outer_start = start;
-- 
2.15.1

