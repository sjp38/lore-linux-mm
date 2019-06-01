Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E89DC28CC3
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:17:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED75B27251
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:17:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="sHpNuSFm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED75B27251
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2A716B026F; Sat,  1 Jun 2019 09:17:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98CC86B0270; Sat,  1 Jun 2019 09:17:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DDA86B0271; Sat,  1 Jun 2019 09:17:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 42B5E6B026F
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:17:54 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d19so8251879pls.1
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:17:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dptnAhz5RBPpHRHfYkvicw5QHXQnGBAI+wN23jOI3Z4=;
        b=evUg1R14wsLoIqEXb7PjOuNYI8v789i1uF6aUwd8/OBFCPJ7JQyzypvbDALXtHRB5M
         KpfBIighuvGKO6bB6Hu85Dwv7iGS+3lYmXEkZNz3G4bEk6tqJHlQm/nimyPjlo0hUYvB
         UCgqJO3nczKdXEhwkOHcx21pObzao6CCVk4baZhEsKVmaey9vWTNjec66JZjwKQHrNxt
         UXusyetXEOJesqcWqzdmKcTwvalyqtAScJuroOCSikAcDSYski3zKe02hWG4UO9emS5L
         JPuhOVTB8Pu8klR00PiU5i3WJ0aDARDS+iqo28uahaTvFhd84OqoEy8t5bKgeiTEo6O1
         wfVQ==
X-Gm-Message-State: APjAAAVu9KZsR8zdxE0WjkOZav/ZNErHThjkNYVaHLrioAZqv2k1epXN
	6fXBK8TxVmw+w2MbIUx79l7zaRw/LgSi8WAXz6cBNVpx2vQQ07oKMi3DMoxVohJMitsBye4L5CK
	eupAQMRr9I/4KB0A4oruAvYK9L/k3cyN76EbZilPvAb3IgcyQNbpXWBO6ZDG6N7kFHA==
X-Received: by 2002:a63:2c14:: with SMTP id s20mr15139404pgs.182.1559395073810;
        Sat, 01 Jun 2019 06:17:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4P0hpduejmRWlkis/GHphLJ4LlhasZgp4bamPSUCJ4Pss0VkXjnEzwrrmUFpWktDrYqYE
X-Received: by 2002:a63:2c14:: with SMTP id s20mr15139339pgs.182.1559395073103;
        Sat, 01 Jun 2019 06:17:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395073; cv=none;
        d=google.com; s=arc-20160816;
        b=ZgjZ7UA37hl20y91OJzBmi5t+DqwX60vrxPePcosjFDiG+dYXi0ktwVxRXL7yPViv8
         H1LXesFyFlIVL0QwPg0OHXN2KZTFfVlfhsRcbFX/ZDTh9LGqc71miuohI0BrsYXYxOo7
         4HpzWXAmZA0nJaqJGuoMtQw447Uk4T3iAJWmgay8XTM++jfGqY17D0JSWOZWdOWiY6Uy
         sXWV9+U60GbeOUnRSSHB9hW0gsVlJwj1XxYxRwzpTMrw6nfrACZRjumw08Vgr/Bz85JL
         0nOxXpGNOp8G6eYGggoQtzSISyM4x/a3bJHxVnrUMeyljMTVKmLoLdvktFApY6SOjT8J
         8K2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=dptnAhz5RBPpHRHfYkvicw5QHXQnGBAI+wN23jOI3Z4=;
        b=hhW50/KdoVP7elVy21HM45d+5UIeDDuzngkm8B4YSRcO2c6hjuh84m/ECqMpxGkQGp
         pvkl3qSR2ip/MJT2izYYbN05JnKHxXL52ZJxWckvWmhHtwvHWH/v32BkxkHilscPaPm2
         HFKfPVvuQEAfTWgPgUErHo/zbWOd2kcZr1kqJK0LeT0vRNQtyhCGzCgSH58vBA7nYtRK
         LbEfE0v00JmS88voLtnxjXyx9bb7XmbavNlTVU21Gop6in6tRqvL3A4M6QeoVLqZ2+S7
         dkMV/TxA6JxzEEf3K39o/rO3H3f2PMEXMWcqCLaucrJBgy0xw3TwgAsaY6z2Gp8J4Ldl
         yS6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=sHpNuSFm;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o31si9652080pje.45.2019.06.01.06.17.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:17:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=sHpNuSFm;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 73ADA25525;
	Sat,  1 Jun 2019 13:17:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395072;
	bh=B1J+LEftpT2eJ8CNTcSUayV3uaqVgtvofuMySmehwFo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=sHpNuSFmbOrn9rekG1Bxye6ZCyacrs1xTNf9ToWq/Q+2yH3VvdETLwL53F/4pqw11
	 2igMUZT07ZGcb4KAO0LNC3L6PTQLvJ7/cr6iElTh1fTvrnCWybfWKuUAv8uFj8mZRo
	 2IX5VH3/44iwzPs52VgK8Es6tnUm6uPKduaKCUgk=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Yue Hu <huyue2@yulong.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Ingo Molnar <mingo@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Laura Abbott <labbott@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.1 019/186] mm/cma.c: fix the bitmap status to show failed allocation reason
Date: Sat,  1 Jun 2019 09:13:55 -0400
Message-Id: <20190601131653.24205-19-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601131653.24205-1-sashal@kernel.org>
References: <20190601131653.24205-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yue Hu <huyue2@yulong.com>

[ Upstream commit 2b59e01a3aa665f751d1410b99fae9336bd424e1 ]

Currently one bit in cma bitmap represents number of pages rather than
one page, cma->count means cma size in pages. So to find available pages
via find_next_zero_bit()/find_next_bit() we should use cma size not in
pages but in bits although current free pages number is correct due to
zero value of order_per_bit. Once order_per_bit is changed the bitmap
status will be incorrect.

The size input in cma_debug_show_areas() is not correct.  It will
affect the available pages at some position to debug the failure issue.

This is an example with order_per_bit = 1

Before this change:
[    4.120060] cma: number of available pages: 1@93+4@108+7@121+7@137+7@153+7@169+7@185+7@201+3@213+3@221+3@229+3@237+3@245+3@253+3@261+3@269+3@277+3@285+3@293+3@301+3@309+3@317+3@325+19@333+15@369+512@512=> 638 free of 1024 total pages

After this change:
[    4.143234] cma: number of available pages: 2@93+8@108+14@121+14@137+14@153+14@169+14@185+14@201+6@213+6@221+6@229+6@237+6@245+6@253+6@261+6@269+6@277+6@285+6@293+6@301+6@309+6@317+6@325+38@333+30@369=> 252 free of 1024 total pages

Obviously the bitmap status before is incorrect.

Link: http://lkml.kernel.org/r/20190320060829.9144-1-zbestahu@gmail.com
Signed-off-by: Yue Hu <huyue2@yulong.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Laura Abbott <labbott@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/cma.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/mm/cma.c b/mm/cma.c
index 8cb95cd1193a9..5e36d7418031c 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -369,23 +369,26 @@ int __init cma_declare_contiguous(phys_addr_t base,
 #ifdef CONFIG_CMA_DEBUG
 static void cma_debug_show_areas(struct cma *cma)
 {
-	unsigned long next_zero_bit, next_set_bit;
+	unsigned long next_zero_bit, next_set_bit, nr_zero;
 	unsigned long start = 0;
-	unsigned int nr_zero, nr_total = 0;
+	unsigned long nr_part, nr_total = 0;
+	unsigned long nbits = cma_bitmap_maxno(cma);
 
 	mutex_lock(&cma->lock);
 	pr_info("number of available pages: ");
 	for (;;) {
-		next_zero_bit = find_next_zero_bit(cma->bitmap, cma->count, start);
-		if (next_zero_bit >= cma->count)
+		next_zero_bit = find_next_zero_bit(cma->bitmap, nbits, start);
+		if (next_zero_bit >= nbits)
 			break;
-		next_set_bit = find_next_bit(cma->bitmap, cma->count, next_zero_bit);
+		next_set_bit = find_next_bit(cma->bitmap, nbits, next_zero_bit);
 		nr_zero = next_set_bit - next_zero_bit;
-		pr_cont("%s%u@%lu", nr_total ? "+" : "", nr_zero, next_zero_bit);
-		nr_total += nr_zero;
+		nr_part = nr_zero << cma->order_per_bit;
+		pr_cont("%s%lu@%lu", nr_total ? "+" : "", nr_part,
+			next_zero_bit);
+		nr_total += nr_part;
 		start = next_zero_bit + nr_zero;
 	}
-	pr_cont("=> %u free of %lu total pages\n", nr_total, cma->count);
+	pr_cont("=> %lu free of %lu total pages\n", nr_total, cma->count);
 	mutex_unlock(&cma->lock);
 }
 #else
-- 
2.20.1

