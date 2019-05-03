Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25A3DC43219
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 19:05:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC4742075C
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 19:05:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oCkYMf0Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC4742075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17A546B0005; Fri,  3 May 2019 15:05:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12B446B0006; Fri,  3 May 2019 15:05:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0423F6B0007; Fri,  3 May 2019 15:05:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id B041E6B0005
	for <linux-mm@kvack.org>; Fri,  3 May 2019 15:05:06 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id o17so1172558ljd.2
        for <linux-mm@kvack.org>; Fri, 03 May 2019 12:05:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=N0fQvI1xQxBGYfgDEPylqO9omVuCnLxv/R7iHJbfjSs=;
        b=DXcr3ZQZjB7GEOD9WD5bF1IV/J/OD9R8ASYNQokE8jz8VnptbYbbbB3bwdvMsLupRj
         X5hW6mz9L2uOYZUJlWUBmWvReErqH9memKhT7Et3ULQ19FHbCoIELYUApoqixN36+13d
         MGEQOrS2IZU5e9AIOSCG9Ghl6hvdpjMPzEzGZAHRFGC1v4H1WTfQmtt72jlhAnyQdOQJ
         OjSFq+4WbmvXndXZH/KTx9VZ5mjsQJ5yjMAPfQa77jpvXXEvQPrdzhZYrlcD2sABL1vD
         fQYDe2y+3acgWWpW/Y7FYM1YaTjyYnk2emYvLq25uaZd1mHYTCqR1puRzhioJiqHAbPP
         Ns7w==
X-Gm-Message-State: APjAAAXuNi4HtlznOi8UKbPWzSyF9n/cJnQfwotcaT4PvuSkJp3t43ei
	mIFy+zA4bwEZBkQDJqpMyXhrviup5YKmzC1uVE5zTlZBNt15x4fxsGQmARNRpFcTg/2G17SE6xy
	9fomgGlkOtDvjaN9ul7DG8cNSGMNL82NDU5PEHhd1vSGElhidbIfR0WaQWwpN1UikYQ==
X-Received: by 2002:a2e:390c:: with SMTP id g12mr6437943lja.174.1556910305816;
        Fri, 03 May 2019 12:05:05 -0700 (PDT)
X-Received: by 2002:a2e:390c:: with SMTP id g12mr6437890lja.174.1556910304714;
        Fri, 03 May 2019 12:05:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556910304; cv=none;
        d=google.com; s=arc-20160816;
        b=j4e3a61e7GFfoVgY8f/Lfv2NWBEoExAM9Yel7fTggUVgbd1y7RZInPsWz3tVNOSqYa
         wB+ufLNNV4tFQ6h5tCrLaWcoDWT9tjVUnyYpn5nqZB3ilBPkKkIe3+4J8rzRsN4Totqd
         T1MvfvYCHcNBud0/uWktmXl7JFc19UnLmi1kjyJV555OHNLEDjtH9PMxHmCHRaUhnqmJ
         On5jFsBSRS1ATZeffxPg3c2+1RitO6a2dKWsZqtTIpbDGUBDqExJJcg0T/S4ScpprglQ
         v9Z41dj3V7WrI5cajQ8L/VTXYVYu5zrbHgwoCyjlUuh1K7Zb2u/ztE/Cq9z2jQRaiRko
         ydww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=N0fQvI1xQxBGYfgDEPylqO9omVuCnLxv/R7iHJbfjSs=;
        b=zN+TuGxtc1poYdeB0rC4qdMtPnGBN851k563Ur0/3lu0BQhvvKrJYZ8IT9t2m69ums
         0gH0QsASswQVm90kyfhQJ6213339GOJC5Y51Rl80puKZyDDvKcD0vy3yMwID/2hcvPtk
         VKhsLM9I6t5gg7IBbuhtDwDpNZWDWGgZFPoM2o3nIHcEKvjtN3xXPPDr2lj58KWKkDtE
         s21AXWvQbBWgAmkHiPSNOZnT2Ct8GpZWkMiWwgU2rpnd6+J3eEWBANAv2+i1MCN7e25/
         6GOkVV8Nyr2WV9Jqt29neSsh1bLO5sSTLwHwZIBZpXnvVVp70EXhNY9F1g7Ue+OsM/GJ
         0z+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oCkYMf0Y;
       spf=pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=adobriyan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x14sor1004776lfn.31.2019.05.03.12.05.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 May 2019 12:05:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oCkYMf0Y;
       spf=pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=adobriyan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=N0fQvI1xQxBGYfgDEPylqO9omVuCnLxv/R7iHJbfjSs=;
        b=oCkYMf0Ylg8SFgR+FHDlyuOt1BjKl/MRN0ULbEKCcIFkm8RjBQYqY9fIvL6SNbxV19
         KE353lpDaTxzO615X6/uVjGYLQxrPIh7tjmOaOmmDG+8LU7z5UGEJqNVaZ+O5tG9XXca
         MtLpT0ELKPHWFWnXoo6AxkigD3S+AmDaoi45yu8YCsf/3XH3XUsOeHWrZapKP3TxVxvn
         bbkcmvbAXnYwf+B3SdQaEtkLzNHtwUnoj0NaP6csUg+X3ShXvMZu15jyj8ImuBs1cS4d
         LlDDfKCE8enCW+fiyCg6feuvrGGehtGCVMvx1I8QxYXDX3qGdxVNo9Q7+eCpJE6vvSlO
         IqgA==
X-Google-Smtp-Source: APXvYqzbLzMgAIFWGOemug1Fm4h55QT+QG7eoUPAMm7rSN4A9ytMBPSmg4cWFVTp9HPqEYJzFpCEDg==
X-Received: by 2002:a19:a417:: with SMTP id q23mr5853317lfc.110.1556910304078;
        Fri, 03 May 2019 12:05:04 -0700 (PDT)
Received: from avx2 ([46.53.252.190])
        by smtp.gmail.com with ESMTPSA id q21sm568244lfa.84.2019.05.03.12.05.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 May 2019 12:05:03 -0700 (PDT)
Date: Fri, 3 May 2019 22:05:00 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
Subject: [PATCH] swap: ifdef struct vm_area_struct::swap_readahead_info
Message-ID: <20190503190500.GA30589@avx2>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The field is only used in swap code.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/mm_types.h |    2 ++
 1 file changed, 2 insertions(+)

--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -326,7 +326,9 @@ struct vm_area_struct {
 	struct file * vm_file;		/* File we map to (can be NULL). */
 	void * vm_private_data;		/* was vm_pte (shared mem) */
 
+#ifdef CONFIG_SWAP
 	atomic_long_t swap_readahead_info;
+#endif
 #ifndef CONFIG_MMU
 	struct vm_region *vm_region;	/* NOMMU mapping region */
 #endif

