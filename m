Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEC51C282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 09:54:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 957692229E
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 09:54:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 957692229E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F5D68E001A; Tue, 12 Feb 2019 04:54:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 27E1E8E0017; Tue, 12 Feb 2019 04:54:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1721E8E001A; Tue, 12 Feb 2019 04:53:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 99BD38E0017
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 04:53:59 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id 39so1948911edq.13
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 01:53:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VWzlY1PPQ+/67pm+/z2QkBDdCvOyUHPQEXMFpI7S4nM=;
        b=hcC7eo+ZL0HTVGPMtI6OWkQc9DlNmTsqj11X5B7MzvFuF/UD6i+EXArbhoUBEjmVjY
         tvvWNBvCH2ws7tttZD4Q4yqLHvtJrdOm6IWrx8vN5LxC1bs4C3aqKt/H7vu5ITq/tef6
         3qe0PZR3tlKrvJ60TCbUVmaMJEXZeoaECIsRWwbevi3eseqypGe/p1LzVk8YaEMbm1ZU
         OsGAXn81ZojqOknVEi/7r5PrZ3JH2cyz4KGTb3ZzqGpHIy2NC7tKY4IbLK2E/tc3qUHY
         7oPbwMEofxyR9jimKXHeH9sYm2b7yaF0Bb8k/kMe5K5vGufENRioDkYRHHeIvTBIVrFE
         x/ng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubQoSET062OCExuOlS6mXV6Gdxfdr09DIDKMvT02v3JzHtgcZCI
	rT5xEZTQcOzxisCFdg0drRSGz0uXE00o+nDklndLWUN+dIuUYBxeAEu4iOG5zcUP2wteEPZik2Z
	WY+4UfZj7cyuXNyf/iDuH7QR3cA8u3ci6Xfv1sM2CPq/Hob/x7rFnT/nsgujMxuB4lj6yzBBq+h
	5cgwN65mEfFXGwmPC1Thw86ooL1UEMDTrF/72G9C+ISk95844h6OF9ph408Zrc5LyiAX0PiIgT5
	ktCgyO1DxYYef1ravFCPH7+u5wAox21lbdRzzqsWSDB9Ssg7zneAtLtxtNWiU3kDixxC6gmh+iG
	M4pp3yjjYcEH5bUjlWG0/dSpcL7K6OW7Ot1OvdFuMoeAFZzn21dqHlbTvKZ2Qqfv5HXYmaprZQ=
	=
X-Received: by 2002:a17:906:1cd7:: with SMTP id i23mr2060261ejh.150.1549965239136;
        Tue, 12 Feb 2019 01:53:59 -0800 (PST)
X-Received: by 2002:a17:906:1cd7:: with SMTP id i23mr2060216ejh.150.1549965238100;
        Tue, 12 Feb 2019 01:53:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549965238; cv=none;
        d=google.com; s=arc-20160816;
        b=XR/XdLluRXr560yUzDwaT89fyVKSaASeX39YFXUh6BZgU6YM64/yvTBAtuvMQrsbfe
         LVEMkBsH8tMe/aRCXDjoBGJ7P89kErraGs+6w2/YOGwoRVLBQy8LXi09QcxiwJ/OBdLa
         joTXwjwhwJ8j9AzXZBSfV8tCQegSXVELqaH1kki7su0y9CSh+p4InHc9/toZGZsnYaDv
         2axBrSp9mO5MArhxJEaEmKbGSJSWqL7zcssHtvxjBzhSZiMmDHrKPKJ03JyEgGIjSFCb
         iFGmz1dUfdWQSC+qagPaVXIev039kmwK39HU6BcKjEze7y+QXkAFls9AdtzkMkrK2VPa
         Gf9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=VWzlY1PPQ+/67pm+/z2QkBDdCvOyUHPQEXMFpI7S4nM=;
        b=CjR32sk02XeKOOFL/G1kFFoO8UahqjaX3JVOgw1wI0TjzY7Y2KqBFguC1SrCxfPUBA
         d/apsoGkTlauNqgNZfVJUGUU0eees8MWZnzN+pVrGLDMUum3qKpkDsa6+zFhJRH+748R
         oF5SIAFBMcjqcTcAItrWJtC6VZmMeF5yEvHivmpGdxBRaUxd4SatlftNgdzJ1b5C65o3
         lDCNgEbC6O1xKCSsz2wq9biQ+PhWquvxLJs9xSMjXiFNjTX3R3pH01q9m+G0/u2Emdnc
         LWvI65ofTMVreqGBtBJ1eENlMmCBS5ev2PYT00Mzw+zKKlBpHXTPV5CiSpxjsrZPRwgS
         6c5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q16sor3664568eja.28.2019.02.12.01.53.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 01:53:58 -0800 (PST)
Received-SPF: pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IaDbQaoXUddyxRvptd1P3Q3Dkjw68Kopy2TfOs74h07Sehg+Np/NzTW4ul6z23IsVehH0xtyg==
X-Received: by 2002:a17:906:18f1:: with SMTP id e17mr2093489ejf.82.1549965237531;
        Tue, 12 Feb 2019 01:53:57 -0800 (PST)
Received: from tiehlicka.microfocus.com (prg-ext-pat.suse.com. [213.151.95.130])
        by smtp.gmail.com with ESMTPSA id i14sm2876791ejy.25.2019.02.12.01.53.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 01:53:56 -0800 (PST)
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
Subject: [PATCH 2/2] mm: be more verbose about zonelist initialization
Date: Tue, 12 Feb 2019 10:53:43 +0100
Message-Id: <20190212095343.23315-3-mhocko@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190212095343.23315-1-mhocko@kernel.org>
References: <20190212095343.23315-1-mhocko@kernel.org>
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
 mm/page_alloc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2e097f336126..c30d59f803fb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5259,6 +5259,11 @@ static void build_zonelists(pg_data_t *pgdat)
 
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

