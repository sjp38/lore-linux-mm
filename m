Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04B56C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:56:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9DB121734
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:56:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Uw1olshV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9DB121734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B5688E0003; Mon, 11 Mar 2019 15:56:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33B648E0002; Mon, 11 Mar 2019 15:56:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DDE68E0003; Mon, 11 Mar 2019 15:56:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB9118E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 15:56:25 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id z24so250001pfn.7
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 12:56:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pe7fBKXi2vg70aJgC7zEaltOdLH8THlAwW2CkcflE7I=;
        b=qGp2axpas1Y7UnaAmpActcmMMFNa/LU63CjtOfFtX4S4Lw3maaqjXV6d6MrI6w3D0V
         jfPvdzFaOJxeVE4Zs5VM0jqUXfXjEhAVLNJLvphSxc4RxwsDixIsfTVLFEOdWIuqPKN8
         tpfoTSXogxsJ+2bSmmDlPILPRlhB66sWhz6Ze9lr9SGSVLWAq1MSLfxbUqkBI6H3u2MX
         QfvTY73lLxC/tsDTOH7QeGlmxweA1CsUAJfPYtUew4Z1lA5kxVEZS83Z0c3x9d4dJxJ1
         Q+F+RC5qfOOy0nNe3TsSRcv74B957Ih43T6q5MhM4lHgCTrH8cw2VAtk9Fw8glPAavJp
         wsVg==
X-Gm-Message-State: APjAAAWlY5Tmmoc3t0um3nwnyThlc1dRUsLoSJNZK2jIQ/0cN9y8g3HC
	9zDrhXEue4w6mFCH7GI2pM82wkRrR22/8/nNX6FHOyp1QPRGHICow6tog/yW5GHP0HgZI7/nb+I
	jr8mSfkivkWQO0rjVXj35NuyFkCLcugOt+iLOq3DTvribG4vl//OV0Ysa6bSFzWOapg==
X-Received: by 2002:a65:43c1:: with SMTP id n1mr32009293pgp.248.1552334185438;
        Mon, 11 Mar 2019 12:56:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsykM00VuEVTc/adZGuD7WLr/ThlyROl4jiuspnTtMZZ3j4ZBsmyQwDRcTMS6WR56CXRNM
X-Received: by 2002:a65:43c1:: with SMTP id n1mr32009244pgp.248.1552334184672;
        Mon, 11 Mar 2019 12:56:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552334184; cv=none;
        d=google.com; s=arc-20160816;
        b=QeL8ETR2Ca2r+xiZ1ZQJ4mGiEe6WkVsx9eb+TMqQo79qQbmfbR5Ffjsoz2dVNyqlUp
         09ZO3+Xi9vuiVDwW7Jxm7Ne8CZnWLjCQRsfjFdXUJpOnTmtZP1xJtKzetQzLqSfLD1g/
         Ud9wRJwQitZdKTEsql/OzRsCvDaI2imRq2JzNp41b2U2SZJM9aFtqvoPaInVMUobOb3P
         xNeiMk09rLzekbztcKuJd4uNdamxGDWEFzK0wJ1Yybft8exPFjy8bbdqWhYtwGQQLYAq
         bkOXPCPBZSWDB24De3AGae7avhnne4M2wrbKJaTYhtA6FmazLUNzY9emIJ5bUh3VNofM
         0oXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=pe7fBKXi2vg70aJgC7zEaltOdLH8THlAwW2CkcflE7I=;
        b=Ok4CnhjWe5CiGYHYWJgUV7vLYEKS+y69Jzs/F4NeH6vvjx+FDhgKadA6Lc6F4DSzZP
         XPAXY28dOcusB3x/I2leTFs0fLIh9LymzCCdIFRb1YNlrJEAy39JXVid7i9q7cfDPapw
         OOyICjR9QftKxkcumoamhRVKGrB/m4F/viq7UzrYCBL8I+tLMhk3eYRs1AXzgO6NV2nX
         0KF8ZojUZrLPXiYegxpsQad+ngPyW0N5eFq1P5kMKGqbEQJxBeThTnApsZY9QzpvnMV7
         h55V+gJ2Bz+UnJytjeo9GETa1mm87Cb0PTBxeSsql52R8aq41joYwAh1xbvx8zDHceQg
         VIrg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Uw1olshV;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d8si5475962pgv.53.2019.03.11.12.56.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 12:56:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Uw1olshV;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B3CC42087C;
	Mon, 11 Mar 2019 19:56:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552334184;
	bh=Re6qNmLU2QxAtKGU6SabD/4R5VKddgRzLOQzWVd+LBo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Uw1olshVdYh2JKcpU47kkWGtrnRVAvClyq/D+AQerZX0aDc8lI2Zy4dYN5bb489QV
	 1giLaCPTolVQxJcWWDwPlWcWVzBiT1N/2yjYZEY1B0RvasxIkMVG6+65jrsrYStpNu
	 nPyP7btPBclwHv/jht3txWKaVg/XwYpaxKxbKM/U=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Yu Zhao <yuzhao@google.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Huang Ying <ying.huang@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Keith Busch <keith.busch@intel.com>,
	"Michael S . Tsirkin" <mst@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.20 37/52] mm/gup: fix gup_pmd_range() for dax
Date: Mon, 11 Mar 2019 15:55:01 -0400
Message-Id: <20190311195516.137772-37-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190311195516.137772-1-sashal@kernel.org>
References: <20190311195516.137772-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yu Zhao <yuzhao@google.com>

[ Upstream commit 414fd080d125408cb15d04ff4907e1dd8145c8c7 ]

For dax pmd, pmd_trans_huge() returns false but pmd_huge() returns true
on x86.  So the function works as long as hugetlb is configured.
However, dax doesn't depend on hugetlb.

Link: http://lkml.kernel.org/r/20190111034033.601-1-yuzhao@google.com
Signed-off-by: Yu Zhao <yuzhao@google.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Keith Busch <keith.busch@intel.com>
Cc: "Michael S . Tsirkin" <mst@redhat.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/gup.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/gup.c b/mm/gup.c
index 8cb68a50dbdf..668f6570ee01 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1674,7 +1674,8 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		if (!pmd_present(pmd))
 			return 0;
 
-		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd))) {
+		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd) ||
+			     pmd_devmap(pmd))) {
 			/*
 			 * NUMA hinting faults need to be handled in the GUP
 			 * slowpath for accounting purposes and so that they
-- 
2.19.1

