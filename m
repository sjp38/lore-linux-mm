Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FA58C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:43:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E141821479
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:43:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E141821479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76A416B0003; Wed, 19 Jun 2019 01:43:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 719998E0002; Wed, 19 Jun 2019 01:43:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E2178E0001; Wed, 19 Jun 2019 01:43:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1271B6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 01:43:52 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b12so12694913ede.23
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 22:43:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=suPCocrA3QM64gsofO1CrTBeyBcHKAtqoGrxzUvLo4k=;
        b=kPLw+PqESArqxFDnZNMeFIVkQyP7GC/AxzLUCEH32qH1HIMXs2IO0BmEhCt72XfAi/
         UU2XqRAxdQdVTftQmKJpuhMKqEKWGXL3Rcxpu+wJJk5mZZTFpqGLwnxppqvH6yFUxzL4
         SCCThGbgelZi7QLY7rdh/mtvCW//gikPfz3EQOESThl/dlR1GucALHj/vpm4X/H12/WM
         mR7BEbLQks8vqags9WAle/cyP1CGTpGQeeTWvuubDhDLsWm+vP8cCSzo6Yqoss3zBCNv
         uux6s2S23YzNMzKvQ4LMHUNrrL2ba0X6iDzSJcfsmo/ktY+ncI5MFRJ/4g2WV+KK7jlR
         1HGw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVWcwzEvXb7+rLfBXi3OAJK/XYW3/aa8d4iBW7tK6wcrHQxOq0A
	98072NFI/D4vEtQnUueGEdts8zlE7Sz+FrEe1YfMGHuHTCAiz8mu1iXIGXSWmYbfvVkZkfqsPoa
	+1E9cG6T9SFqsYrcXuwmh/M1aqHaVJRR4DyDpAYaWO6vRr4fEyQ3npd5UQ7CVqMk=
X-Received: by 2002:a50:9431:: with SMTP id p46mr111973935eda.38.1560923031620;
        Tue, 18 Jun 2019 22:43:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2L4qpQjMhz128SnGS5MRrQbLtEb908yDTl6OAnpuUwYYNERYargIGvBucY91n9EgkqBvV
X-Received: by 2002:a50:9431:: with SMTP id p46mr111973887eda.38.1560923030680;
        Tue, 18 Jun 2019 22:43:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560923030; cv=none;
        d=google.com; s=arc-20160816;
        b=0mqMEuv6jVqny/Z2jW2vRHpki+XQNpKjn6bdShT5Wue7N5QXN6Nm1eEH+5eeXl9pXp
         nYUX5fL5WyCA1UJI2XR++gIReRAulxYhfeYxTi0JE8oh8WkgiRYaTW+dFOHFVgSXhhEq
         7v6BjfNugRdpbo6o+rInuDTLGqHPLLZSU4HBHoFH4Ig4v4qy9MP6IFVOEkxfqSOOIDof
         VXPK0Uh8tLkhNZ3TmH20woZFkKcMf6EdMEPx4J3vqiQ8aqn9B3d8tZxvTcuHHtbTRaXq
         N6lUx5kReiqF4XvWjFCp3Db+nvpztAbXldBsimHu6cijFi+5aBtLGLVCwBJrjGNdX3u7
         Nh3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=suPCocrA3QM64gsofO1CrTBeyBcHKAtqoGrxzUvLo4k=;
        b=q4/Ywq7J/9da3+o2uHDishWhMVDwK49rqivHRdd+I1aGdgXVd0KwuzJTVYGZoIl/Ow
         5V0QH5xMkBBx7pL3FJNBDJowxHkbYRb25gNZq4anILA1vm1TYdSIapIzTscqG1tY/b+A
         Z7ayTIOJAkT3LI60ohOAvzYM+ZRKdZHrSloiPbEkv/qMq1Q/VocDOpG1y1NPZO//2MYl
         c0CD05VDwOC7SFYeZFNfr/UxpurkSXctXgi+6BS9uw2fdduNgL0U0HgPXZoib6mfEEOx
         4SRq4koIFzJIIscqbPgQEtqg83hhH+oOdfvgdaYDn4Df3//NDL/RAJRTusqLCQgT5OHX
         Sk1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id i2si10343447ejr.16.2019.06.18.22.43.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Jun 2019 22:43:50 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id AC264FF80F;
	Wed, 19 Jun 2019 05:43:39 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>,
	Helge Deller <deller@gmx.de>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S . Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H . Peter Anvin" <hpa@zytor.com>,
	x86@kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	linux-parisc@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH RESEND 1/8] s390: Start fallback of top-down mmap at mm->mmap_base
Date: Wed, 19 Jun 2019 01:42:17 -0400
Message-Id: <20190619054224.5983-2-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190619054224.5983-1-alex@ghiti.fr>
References: <20190619054224.5983-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In case of mmap failure in top-down mode, there is no need to go through
the whole address space again for the bottom-up fallback: the goal of this
fallback is to find, as a last resort, space between the top-down mmap base
and the stack, which is the only place not covered by the top-down mmap.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/s390/mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/s390/mm/mmap.c b/arch/s390/mm/mmap.c
index cbc718ba6d78..4a222969843b 100644
--- a/arch/s390/mm/mmap.c
+++ b/arch/s390/mm/mmap.c
@@ -166,7 +166,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	if (addr & ~PAGE_MASK) {
 		VM_BUG_ON(addr != -ENOMEM);
 		info.flags = 0;
-		info.low_limit = TASK_UNMAPPED_BASE;
+		info.low_limit = mm->mmap_base;
 		info.high_limit = TASK_SIZE;
 		addr = vm_unmapped_area(&info);
 		if (addr & ~PAGE_MASK)
-- 
2.20.1

