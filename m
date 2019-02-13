Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E425DC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 09:40:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9FC3222BA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 09:40:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9FC3222BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D1468E0002; Wed, 13 Feb 2019 04:40:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 358EA8E0001; Wed, 13 Feb 2019 04:40:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1FDA38E0002; Wed, 13 Feb 2019 04:40:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id BB1C58E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 04:40:45 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id b186so346709wmc.8
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 01:40:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KPQIvusfQffcbSiTMJqq6ntVvlDynZgSpryXWkwTGaM=;
        b=YbNHc8vHUEF5MmMVeCHITnjJcX3vGXJ9IrK7l0gKefZ6FOwFEGxXDfXuyDiNgxUuYJ
         YzW7fcjPfDJIxW7SAAK1N6osDFLzaNvefX+g+q6NxVBt27YWORbIZmfhgj1CV+/y9YDo
         NSSZQjXtAqHRqPo8X4j5zyGrG3c0JuYi/AFbe8EvLKjUMkDEtJkIT18nLEFd9SE6YhFQ
         NVIUoUS7qe9fSNqd/t8ykXtI3/l7S1oXB7cgM7Q9fdx845sphngx3rnj62Ipd1n09sRe
         CXzkTl/3GX/Tx6URL6hKWQWfh7VMJap5oq1nQ/J+PhjveQTOJGvlmMstW1w+AoQ3wBhp
         0uXg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuaU5upIylwCnx4UC6JrRVKQr9rhKNUN4/XjB4dXQVbV8XczAmbN
	c7NzQpTK0k4+45VNFcnk3UFZDW70yaFv4x9Ge4IF5t4v6a0hdkLQ7A1W1Ek/SX70BdRaeyR7wl0
	GUQXB9bDX+HdDtQsyAUvm8e4d4QPdrYwHGZeeTeqR8nuR2xVzUfEmuJJgjzXBNlkEPZ3UwqN2Ap
	AXJx2gwBnRD1gXBooYI1GZlAYtfusTBuCMLwXRW5vk3iqJ9tQIwnTrvBWYvX5qw/Hxvpgwm0Ar4
	8KGDbjsn/UR+aaGeB95dUmGAMu0joVtunFFX9IFS5SIuiadCAAydmxEunGu/gEiY/g+ewsSyVUI
	QN8IXv7nmhNBCFaM5rDqAgvFfqm/4m0864fNEjoZDpfWlNaDuQcy/TY4HMyZZK8GxGCXVyXI4g=
	=
X-Received: by 2002:adf:8143:: with SMTP id 61mr6068742wrm.47.1550050845330;
        Wed, 13 Feb 2019 01:40:45 -0800 (PST)
X-Received: by 2002:adf:8143:: with SMTP id 61mr6068691wrm.47.1550050844371;
        Wed, 13 Feb 2019 01:40:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550050844; cv=none;
        d=google.com; s=arc-20160816;
        b=P88oHdDUkG+rnM4bGx/FRiR7+I7Dfz4h4qRDnBP6jk01Jvfu4UWCfjxxaHqBXwv6pi
         rNXIhCA3diYV2+2lH1nP33PPB8n7w748ahxnpkEZJ6IxGO3g4tN4gi4OjoJj5wR5R1z+
         WXeB5DOR3PFK6QPHhWcz0G6z+ZgmhDXDRH65QL+iSPZV1QOIRS7Me3c7CSKYRLvHRAPZ
         8cBdwbn0WQl1sW2q/1R8HD3dwHZdfRNnY5WnuQ9iJRrXj4ClyvFiPyQ94znwKVeia/wW
         tc2a7tsI1mzzlKmCwkfHYGSvSygXLfQBy4Y0gESViSbCVsLschTCO0SInKbiRVF8zf63
         kP+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=KPQIvusfQffcbSiTMJqq6ntVvlDynZgSpryXWkwTGaM=;
        b=AJSswUxWfco1wQp8UNayprjji2bLFFGFAIr2SIlf3rLy6q1iouMY0h2EXzqyAOerTV
         HZTKWn8jvEK1ECOAaAI9KGnrZdLG171UMjnNliuxt+zk2LKuwwGYfEndA/4DVjwc/Ray
         dyViR39Zw21xyxiaj16X+UtylvfeagOSGtkD8bkbkClKYwxhSdA4mKEM0KSKdQ0fSkER
         J02Dacb7+C36jC3Wf6Qe+rg6pT1ZA+3E419hq4KJ598ime5o34p55sojtO1pC/uDlfLr
         PMIrJk/PBZ10rtDULwqRkPMHKtqp7qDYc3xbi2S/h4WaD90tHEOy38WjQEvVW1hDZhMX
         eK/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o18sor2550558wra.14.2019.02.13.01.40.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 01:40:44 -0800 (PST)
Received-SPF: pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IZuh4Vbs+i/l3tBIYxc0NPmfUP4uiVUoKfoZUsXIyJmFEXYRFSSKGguAs+YWrr2sqbfmcUeRQ==
X-Received: by 2002:adf:de83:: with SMTP id w3mr6080776wrl.56.1550050843722;
        Wed, 13 Feb 2019 01:40:43 -0800 (PST)
Received: from tiehlicka.suse.cz (ip-37-188-151-205.eurotel.cz. [37.188.151.205])
        by smtp.gmail.com with ESMTPSA id i13sm20879739wrm.86.2019.02.13.01.40.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 01:40:42 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
To: <linux-mm@kvack.org>
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	x86@kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Tony Luck <tony.luck@intel.com>,
	linuxppc-dev@lists.ozlabs.org,
	linux-ia64@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	Michal Hocko <mhocko@suse.com>
Subject: [PATCH v2 2/2] mm: be more verbose about zonelist initialization
Date: Wed, 13 Feb 2019 10:40:34 +0100
Message-Id: <20190213094034.1341-1-mhocko@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190212095343.23315-3-mhocko@kernel.org>
References: <20190212095343.23315-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Michal Hocko <mhocko@suse.com>

We have seen several bugs where zonelists have not been initialized
properly and it is not really straightforward to track those bugs down.
One way to help a bit at least is to dump zonelists of each node when
they are (re)initialized.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2e097f336126..02c843f0db4f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5234,6 +5234,7 @@ static void build_zonelists(pg_data_t *pgdat)
 	int node, load, nr_nodes = 0;
 	nodemask_t used_mask;
 	int local_node, prev_node;
+	struct zone *zone;
 
 	/* NUMA-aware ordering of nodes */
 	local_node = pgdat->node_id;
@@ -5259,6 +5260,11 @@ static void build_zonelists(pg_data_t *pgdat)
 
 	build_zonelists_in_node_order(pgdat, node_order, nr_nodes);
 	build_thisnode_zonelists(pgdat);
+
+	pr_info("node[%d] zonelist: ", pgdat->node_id);
+	for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
+		pr_cont("%d:%s ", zone_to_nid(zone), zone->name);
+	pr_cont("\n");
 }
 
 #ifdef CONFIG_HAVE_MEMORYLESS_NODES
-- 
2.20.1

