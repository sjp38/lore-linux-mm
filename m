Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21807C282D9
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 16:11:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8CD32085B
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 16:11:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linaro.org header.i=@linaro.org header.b="NulEkyw7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8CD32085B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 772B88E0004; Thu, 31 Jan 2019 11:11:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7206C8E0003; Thu, 31 Jan 2019 11:11:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6106E8E0004; Thu, 31 Jan 2019 11:11:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id E9B098E0003
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 11:11:03 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id p65-v6so621422ljb.16
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 08:11:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=l8ZZE/CQHJf/B+Br/+OZnPG545feQjEVeVkqxdQKkp0=;
        b=XnOXPVVqzf6DIkpG+M1gbhwMfsJpWK2W9Wxdlpx5HYDVWk2BTXq3NIXCLzH8khlyvK
         7qtZzO1NUTk6NVbbGY5PVkpoVAWeWRHl5vFEuu9vF60v67sfzcykQ/RswUQRQAQBy6vF
         +b2dZ/Qu2QKSQPAAycPFHLrzn0Yv3Em9oNZTjmptC+fiW0onEHctdS2ZVU8uHk6lmHDL
         aB0R4UXlqn/KonsyEWEbWHjGfbz3QDtMYsrRCJAff5dbhc4b/nqO8S/MPJgVWfG7D/Wc
         NZwUPWYcAlMD97CYLrMg7FQ0Q43OpqqJ6z24gSQlJJPK9Cv56ag/M1AVq36ZXPvvVpId
         rUgQ==
X-Gm-Message-State: AJcUukc2m9jtTjKLkMUGdkod8Ac3FJqoP306ufz9jQaS/BTwg4CehUS5
	V9AsnQxOIa24pSy2M8WUUJB+1iesI6kjtvMCOzgBNMRedbErPVcvmgp5PUy0CdMY0wULA4n+r+A
	uRUPZy1Lv90YKWnPzluhy9kyjPOs4RtRlRBP9BGmfcNllw8ArLj5yeUTkcNx7FGcbe9vbg7/oZt
	AP+PdABH1NyCf1ZR8Kflnc97Z1CZaErg6LrNLcs/B0xdhcR2P566VsgPr9FCKllAcno1H5eRQKx
	Lb+mVEMMHcPOp1bBl3ezF9fKiaGxWIxyWgk0/TQpw7hVkB/qVggL5m9SgoJ3yQUiV4ADb7rsUnI
	99VZfKrGtrauHZS2IS7bwWFc0D6MXR1u6EcPhy9r+dpUbjhyk2tEcuQFWZSLzJNM718TT52UyVZ
	I
X-Received: by 2002:a19:40cc:: with SMTP id n195mr27219801lfa.40.1548951063102;
        Thu, 31 Jan 2019 08:11:03 -0800 (PST)
X-Received: by 2002:a19:40cc:: with SMTP id n195mr27219751lfa.40.1548951061933;
        Thu, 31 Jan 2019 08:11:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548951061; cv=none;
        d=google.com; s=arc-20160816;
        b=sDkT43J02jjMsT2H8BHPNz/b0fyR7eGpdD/GWGyT2nu4UrCTnFqVoEMXRTPvH0hry2
         pAMoptV+9m2L+qRG8wc0CKnAtwDVDuDIr2qR6YCL/a2wz/IsocbkGHkRVvjHY9KQMv+g
         i06hOv1dPA73v3OZpjP2/Yivbd0+JZXI8q6semt8KdgxtflJAwH7WXz+JDpOoW0tl6FE
         a31ABo/9pFAbykaM+du192wBKLmtEQcjk1KcAmD4hQrNs+qtbHw/bJHSu7uzgMHVZJj9
         I0MbJFaEmlSjMgT1s7N/QJzAlb9Rzmp81GUzHuTWIB2fTdMUAiwlOVsO/syw1QluCcyN
         5JlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=l8ZZE/CQHJf/B+Br/+OZnPG545feQjEVeVkqxdQKkp0=;
        b=vX6OJ9l8s/EQ3fsQcKzEcPdCJfIMKG/FeEYqkoxJ77ggHyf0b11VSUhCjjCfAHVXeG
         RhpxH3LY+wBuURdipVBQs8wCRB/TVBWiEHyiJw49q263e540xBFFvFXnlq8h7k4Ku8Qn
         b4DQ2IJx/Q9OVJty7Hqd+X3AEgmeij/SHzW2KsuLGPjP7Wq1llp8wABLzGNcxxgzCb8O
         MCo263MYzK8BmMwp0S0SbK9ZoZ4zaOD6AhoD+9/rXxNTqvHr4N1/hVgoAWRCqjX0IW8O
         HDdTT0JTKiwaRJeY13kdrBb35aUUcISdKgUblnvQ668XXIkmZuIOgBF6hqt8wFaterb6
         nj+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=NulEkyw7;
       spf=pass (google.com: domain of anders.roxell@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=anders.roxell@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u66sor1606057lff.39.2019.01.31.08.11.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Jan 2019 08:11:01 -0800 (PST)
Received-SPF: pass (google.com: domain of anders.roxell@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=NulEkyw7;
       spf=pass (google.com: domain of anders.roxell@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=anders.roxell@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=l8ZZE/CQHJf/B+Br/+OZnPG545feQjEVeVkqxdQKkp0=;
        b=NulEkyw7WRGZfONt3e2rFzs9IFb84cAfNJcAgwD/UdiCtw/e5wReNIOU9KHl7SvheN
         0I2NwQRGNpNE212NvAb3sBUsZi7MOhVHNSJviVZHs+BG9M6UVR3gV85ur9rCH1KMgKM/
         f5fTxjcYk3zQnYAJC1Y/Gv+0HBQuJc+JJUGfE=
X-Google-Smtp-Source: ALg8bN5jFb2AXccaSAAVgnX28SjZIcZYLh7UGufvd6HCHsSuZONlbB9tZPsUROf8nbxDO1s9DUimXg==
X-Received: by 2002:a19:4345:: with SMTP id m5mr27334183lfj.142.1548951061287;
        Thu, 31 Jan 2019 08:11:01 -0800 (PST)
Received: from localhost (c-573670d5.07-21-73746f28.bbcust.telenor.se. [213.112.54.87])
        by smtp.gmail.com with ESMTPSA id z17sm324322lfh.9.2019.01.31.08.11.00
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 31 Jan 2019 08:11:00 -0800 (PST)
From: Anders Roxell <anders.roxell@linaro.org>
To: akpm@linux-foundation.org
Cc: rppt@linux.ibm.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Anders Roxell <anders.roxell@linaro.org>
Subject: [PATCH] mm: sparse: Use '%pa' with 'phys_addr_t' type
Date: Thu, 31 Jan 2019 17:10:46 +0100
Message-Id: <20190131161046.21886-1-anders.roxell@linaro.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Fix the following build warning:

mm/sparse.c: In function ‘sparse_buffer_init’:
mm/sparse.c:438:69: warning: format ‘%lx’ expects argument of type ‘long
  unsigned int’, but argument 6 has type ‘phys_addr_t’ {aka ‘long long
  unsigned int’} [-Wformat=]
   panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d from=%lx\n",
                                                                   ~~^

Rework to use '%pa' and not '%lx'. Use a local variable of phys_addr_t
to print the reference with '%pa'.

Fixes: 1c3c9328cde0 ("treewide: add checks for the return value of memblock_alloc*()")
Signed-off-by: Anders Roxell <anders.roxell@linaro.org>
---
 mm/sparse.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 1471f06c6468..6a2b0a9359d7 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -409,16 +409,17 @@ struct page __init *sparse_mem_map_populate(unsigned long pnum, int nid,
 {
 	unsigned long size = section_map_size();
 	struct page *map = sparse_buffer_alloc(size);
+	phys_addr_t addr = __pa(MAX_DMA_ADDRESS);
 
 	if (map)
 		return map;
 
 	map = memblock_alloc_try_nid(size,
-					  PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
+					  PAGE_SIZE, addr,
 					  MEMBLOCK_ALLOC_ACCESSIBLE, nid);
 	if (!map)
-		panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d from=%lx\n",
-		      __func__, size, PAGE_SIZE, nid, __pa(MAX_DMA_ADDRESS));
+		panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d from=%pa\n",
+		      __func__, size, PAGE_SIZE, nid, &addr);
 
 	return map;
 }
@@ -429,14 +430,15 @@ static void *sparsemap_buf_end __meminitdata;
 
 static void __init sparse_buffer_init(unsigned long size, int nid)
 {
+	phys_addr_t addr = __pa(MAX_DMA_ADDRESS);
 	WARN_ON(sparsemap_buf);	/* forgot to call sparse_buffer_fini()? */
 	sparsemap_buf =
 		memblock_alloc_try_nid_raw(size, PAGE_SIZE,
-						__pa(MAX_DMA_ADDRESS),
+						addr,
 						MEMBLOCK_ALLOC_ACCESSIBLE, nid);
 	if (!sparsemap_buf)
-		panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d from=%lx\n",
-		      __func__, size, PAGE_SIZE, nid, __pa(MAX_DMA_ADDRESS));
+		panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d from=%pa\n",
+		      __func__, size, PAGE_SIZE, nid, &addr);
 
 	sparsemap_buf_end = sparsemap_buf + size;
 }
-- 
2.20.1

