Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2710CC43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:13:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0868320717
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:13:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="g2kc9SxI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0868320717
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54BEF6B0003; Thu, 25 Apr 2019 16:13:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D1546B0005; Thu, 25 Apr 2019 16:13:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 371F76B0006; Thu, 25 Apr 2019 16:13:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 11F366B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 16:13:22 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id r13so899929qke.22
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:13:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=AArvo9mgYoyRktAJ5kAP1IHD/6w2H9k3m+2V0Nyv3t0=;
        b=OwYxNJLv+nHeNDBs181GzoB8Oqih0zWTjhhK6OhjuiR2K64cmIEiGJSpA7hqxJCs/j
         FNTcDcFLWtnCleJ3R6IRGQ/9/gBJ8g9t5FABNoKchO/Do4XaEuyQyl/B+35OxoVZpBy6
         gs9e/f+VMMj5NVdA3BETSPDdZpqhCAG+RfRri00Aq+lOuH8UT2QwBNsx/gxUowrj3UIO
         dF3opo2R+6a70EcZhcKiWJtKMDRE4WPpKkoLAJkdZWOavhXmlsJn1A3Q3+Wgfp1Z0tMS
         0faIW1F0FeopfeFl/UYH8J3X3XJHG85/iH8vDJXn1m7ndm3XfTzsYNbn1xXEGh61qnhF
         m9hA==
X-Gm-Message-State: APjAAAW9be04pk4l/CMX0xMZmz7qQFCO/1FE9+7CYOwgdaaVCqj4b0FL
	KNni22SvLeIz4J9FqhtXj9PPvtC9sbhuPei6yWbctilO+Betmj8NvXlJefl3IQkk/cQx/XTdDT4
	rdOK4oSYIhoR6meBzofCnmT0dlHIGJfMGZeAwUuQBvXgw9dNdAeSdZXrUKI8B1K++mA==
X-Received: by 2002:aed:20c4:: with SMTP id 62mr31303164qtb.256.1556223201769;
        Thu, 25 Apr 2019 13:13:21 -0700 (PDT)
X-Received: by 2002:aed:20c4:: with SMTP id 62mr31303121qtb.256.1556223201149;
        Thu, 25 Apr 2019 13:13:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556223201; cv=none;
        d=google.com; s=arc-20160816;
        b=bVHi8L1uv0FagwJZoVdd4G86z2e9zt2eup3Pe9HG302iee0OI5vkFGwi420WHrJG/o
         F8tiaxbXVD+E7oW5BGJtlVcZm8ZCe95EjFRBXFtaQ7XWjCZBLimy1BLvSQBuaqCDrx1Q
         cdWuA8SuHwMDBvaoQM762vul6WPA/hxfKWE8yV0cGvPBkPVfUECXIZ3HU2+8MP4LJ+Wr
         fgjEtppqNk38ztnKXzEhBVTe1YcyaXGI7khwxevTUA/itL0g23YeTtKyt53skAC6aDVP
         eDWcJk+HYcnPptZRL+h8BTf1V5kyMWEvBJ4+wvR/L4y96cPQevYSKOuZ+mR5o7zKkhiL
         7UEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=AArvo9mgYoyRktAJ5kAP1IHD/6w2H9k3m+2V0Nyv3t0=;
        b=CzheVAGOGYXIoDzLQ37tVxUNA/OOv6Cu8UxySdzVBs8GHXvt7cNXaKm3BFemGYlWdA
         DRKdQNOA6ozFpuo30/AacUFF25YXFASRxetjYE4Wm5i9U0xdlwjl1hP/EjqpG9lQi7Qz
         sIkTnfKIwcFAkOMTWga9s+N28xHeSAG0B67RkhQvHmMoVnffr76BAy4k0REgTcIZyvSG
         Owggq4OC4lKafeDE9hSeKutdA0IrPEHkcKqp0qXSXYkQ0uiPAHPflA6Roio21rvCXClY
         75HHxRw7CEmAbr+iDHsdsIgETtTsjKSCE7ahjKpsJvlahOVHrmLTwWAvCPrbrUJ6z3Xr
         o+DA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=g2kc9SxI;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p188sor7956777qke.4.2019.04.25.13.13.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 13:13:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=g2kc9SxI;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=AArvo9mgYoyRktAJ5kAP1IHD/6w2H9k3m+2V0Nyv3t0=;
        b=g2kc9SxIMLitYEl3WzfXsfPFUb3FW8WK6tz6bdm1lGbfjINs0eNK/DiACekas9tQmu
         +3ppF7rpq9gpd9dZZvWWKr9yryfQfx9kXf7WCo1Y/bnfYu3c1ybgO63zP43arqBtLKQp
         YfSKF7LwLBVk7cKX7HrFzprXgWzfqpFgogKE4QEnGT+O5hALzoUcQrKbpgKoGlfx4JMF
         QXbu/RMAwwkwLPnQp8U4OjVi+fnf5bjwIvBA7Rr6bfijYorVgDo5roqS0GIRl4cbIddg
         lH6j93cK/muDArJ9rNLMPycDYZFHEqXeUM8SiROz1UuUoKmWgpnsj0ypFKnniNYVYiCT
         Vk/A==
X-Google-Smtp-Source: APXvYqxWdeFQNXwYx/Pb7laTNOZXPcbZHtqHonk3PSNN7YSDgFQA9pmSCu5+Je9KFjCJzcCZV5wEzQ==
X-Received: by 2002:a05:620a:146c:: with SMTP id j12mr21383087qkl.116.1556223200838;
        Thu, 25 Apr 2019 13:13:20 -0700 (PDT)
Received: from ovpn-121-162.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id g24sm2355837qkm.25.2019.04.25.13.13.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 13:13:20 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: dan.j.williams@intel.com,
	linux-mm@kvack.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH -mmotm] mm: fix SHUFFLE_PAGE_ALLOCATOR help texts
Date: Thu, 25 Apr 2019 16:13:00 -0400
Message-Id: <20190425201300.75650-1-cai@lca.pw>
X-Mailer: git-send-email 2.20.1 (Apple Git-117)
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000052, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The help texts for SHUFFLE_PAGE_ALLOCATOR makes a wrong assumption that
a page size is 4KB everywhere.

Signed-off-by: Qian Cai <cai@lca.pw>
---

Fix mm-shuffle-initial-free-memory-to-improve-memory-side-cache-utilization.patch.

 init/Kconfig | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index b050890f69dc..d96a910369c7 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1764,8 +1764,9 @@ config SHUFFLE_PAGE_ALLOCATOR
 	  the presence of a memory-side-cache. There are also incidental
 	  security benefits as it reduces the predictability of page
 	  allocations to compliment SLAB_FREELIST_RANDOM, but the
-	  default granularity of shuffling on 4MB (MAX_ORDER) pages is
-	  selected based on cache utilization benefits.
+	  default granularity of shuffling on the "MAX_ORDER - 1" i.e,
+	  10th order of pages is selected based on cache utilization
+	  benefits on x86.
 
 	  While the randomization improves cache utilization it may
 	  negatively impact workloads on platforms without a cache. For
-- 
2.20.1 (Apple Git-117)

