Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D21E1C76196
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:09:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EA60218B6
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:09:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="PV36iSu7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EA60218B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A9208E000A; Fri, 19 Jul 2019 00:09:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 359C78E0001; Fri, 19 Jul 2019 00:09:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 222518E000A; Fri, 19 Jul 2019 00:09:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id DDF268E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:09:25 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id n4so14650577plp.4
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:09:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EXtPrFZwRlci8MNOBLGYLwBXGhRSrahHFxmCEZpLKZg=;
        b=A0vARl4Q3xUdcdCIfle6rD56eAUI22tItjqGZmkxYpZcE+e5+fBvjjTvsGxcMXG68b
         k7F09ge4WszI1bCWnWsMtOeYGvUqqPZggRGwl0RLMZMPiA7aYGSzVdyJxFEoS3oJqB/u
         m/EFBpYY0twzjyH0zG5dbzs2Mun78+g3h46DIfkJ5InyoRcRkmqDfFECuOcMR2weJ8iL
         MJX8ZYJIkicRPDdyjmyQj3HdmdoUE+Xm8ih2APdRHkmPVoa1xP2saKuZPfYw1FLnkhr/
         VW7SVdhG1CXngwrz3BLA114rf13lOJPAEsPPZwN6rnAiN59ql2X9jOG5nTmHgaecCCjw
         mHDw==
X-Gm-Message-State: APjAAAXolS8teS5AtoKX3+DCGrSPhzf852ifR6b6po/9d56lCWAP2R5q
	99EQnt/yaUh7agDhcrp6WzADxf/D05Rk5wgX3dpnozccy34Yoc1YynQsgkWDxhvyCcTKtADFz+2
	JZYSDprQZNVavrWD9glDh4CjF85eCZ/exh9feWmT8BGl6Ph3fmxs3LHgtY6LC8Hzhkw==
X-Received: by 2002:a63:e213:: with SMTP id q19mr51004369pgh.180.1563509365441;
        Thu, 18 Jul 2019 21:09:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZPp13zicvHW13lQubiTytYBqXx1teocBI5agd0pi2uJyGSBTWBJiS9sIEEWbQY2CvPheJ
X-Received: by 2002:a63:e213:: with SMTP id q19mr51004317pgh.180.1563509364701;
        Thu, 18 Jul 2019 21:09:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563509364; cv=none;
        d=google.com; s=arc-20160816;
        b=CULSA/RukOM3arvt6RoJw3xB3SJcQYY2iZc4xyitolNRlgG65Ezjk79JvGQFxxuERI
         jUvQGojQJh00DnPSF2DSJWDzWysBsMHz7r0dDcG4ldQKchBrTe3rmqetIZMs1ag+rJu6
         fiXKm1lwe2PbaowHib3M9Hr+TAXzbbvdPrpQrf7SjYL+zt0O2rAdGDAkdHo+hAiS2i4f
         RAii134fyAXH5br71J5ZMnsAbsYUvJ9ED8//6TOr8oD3feghuBGm06SBAKGWE7e3rsZK
         7Krl0sF/jPXSUFm9IJ6nBxi5AQVr2YTvNCce/PIMWGiWa5cHIMuxGYa0f0eZqqhMbngH
         rR9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=EXtPrFZwRlci8MNOBLGYLwBXGhRSrahHFxmCEZpLKZg=;
        b=MmdfNNraDszm6PHvSSc2Ayo0G8pp9DNUBaqzIRBUl5YPzNb2YFTUiGs/g8p7geklub
         K97ep/gBIWBz6RsNFcQIwuHc8kJvUIHNru2F7szeQMYjbkeb/zQ0AeBqgRFViVN4VErZ
         T4vFxSM+u4raxz8i2Gf6DSUTjm56e5tpoTiCY16X+KveWU7mGatjfIbfreg7iHFQgwRA
         9NTbIrtsI68eu65P/qmifTShRvH2TBYYMTdOemH1jzbetgKAyMj81NWaXtnQXjSyrOct
         jnlSyBdzpYHVQLLlrWHTUq5B11kbFrq9NSVdy3sofCfT/YotrwUp1jV0RwCutv1JGjdv
         5l5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PV36iSu7;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 35si497580plb.62.2019.07.18.21.09.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:09:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PV36iSu7;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 54D322189E;
	Fri, 19 Jul 2019 04:09:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563509364;
	bh=bmTFn2nUfqtn9lYCa79Sidrp3U1/aWjv5+bzonW2H6U=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=PV36iSu7F4NEZm28i4ue5LMDmNxsAJaLE8/A5y7NOh5uu563MqFWN3Szz4l8+oA5b
	 ZeQJ6eGoHu08XoRG8TEPudiZhPzhwWMN4Stwjk4/0PVqOJJag4xtd7wgjS9vyKLKuY
	 kUJVPKlNa/P2KjepsK8a73KLBHlLzxXmWPhvw8cY=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Ira Weiny <ira.weiny@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Dan Williams <dan.j.williams@intel.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 055/101] mm/swap: fix release_pages() when releasing devmap pages
Date: Fri, 19 Jul 2019 00:06:46 -0400
Message-Id: <20190719040732.17285-55-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719040732.17285-1-sashal@kernel.org>
References: <20190719040732.17285-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

[ Upstream commit c5d6c45e90c49150670346967971e14576afd7f1 ]

release_pages() is an optimized version of a loop around put_page().
Unfortunately for devmap pages the logic is not entirely correct in
release_pages().  This is because device pages can be more than type
MEMORY_DEVICE_PUBLIC.  There are in fact 4 types, private, public, FS DAX,
and PCI P2PDMA.  Some of these have specific needs to "put" the page while
others do not.

This logic to handle any special needs is contained in
put_devmap_managed_page().  Therefore all devmap pages should be processed
by this function where we can contain the correct logic for a page put.

Handle all device type pages within release_pages() by calling
put_devmap_managed_page() on all devmap pages.  If
put_devmap_managed_page() returns true the page has been put and we
continue with the next page.  A false return of put_devmap_managed_page()
means the page did not require special processing and should fall to
"normal" processing.

This was found via code inspection while determining if release_pages()
and the new put_user_pages() could be interchangeable.[1]

[1] https://lkml.kernel.org/r/20190523172852.GA27175@iweiny-DESK2.sc.intel.com

Link: https://lkml.kernel.org/r/20190605214922.17684-1-ira.weiny@intel.com
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/swap.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index a3fc028e338e..45fdbfb6b2a6 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -740,15 +740,20 @@ void release_pages(struct page **pages, int nr)
 		if (is_huge_zero_page(page))
 			continue;
 
-		/* Device public page can not be huge page */
-		if (is_device_public_page(page)) {
+		if (is_zone_device_page(page)) {
 			if (locked_pgdat) {
 				spin_unlock_irqrestore(&locked_pgdat->lru_lock,
 						       flags);
 				locked_pgdat = NULL;
 			}
-			put_devmap_managed_page(page);
-			continue;
+			/*
+			 * ZONE_DEVICE pages that return 'false' from
+			 * put_devmap_managed_page() do not require special
+			 * processing, and instead, expect a call to
+			 * put_page_testzero().
+			 */
+			if (put_devmap_managed_page(page))
+				continue;
 		}
 
 		page = compound_head(page);
-- 
2.20.1

