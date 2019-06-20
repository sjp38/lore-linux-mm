Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CD23C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:06:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC76D214AF
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:06:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC76D214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76EA66B0005; Thu, 20 Jun 2019 01:06:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71FB78E0002; Thu, 20 Jun 2019 01:06:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60E638E0001; Thu, 20 Jun 2019 01:06:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 133D56B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 01:06:21 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c27so2579093edn.8
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:06:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=srNjincvqY5G24pyZeONdm1hP7PP/oYRsoEsOQD60iY=;
        b=p7rtKItg4HeiBJjaJRNRRWS8UZP8067XRN6QDdISEd9c4iosDTAI93lLRESnY23hWe
         Kkqv8FLUQ982IZgNKVrxD5SLloA2nSXRc7dDMysavY9/UCthY8KdGjzfLgqd3u+NQ4Wd
         VZ5//zMKb/dGpsuc5vaIcTYg5YQIEkDdjGSqAjS0s5NrgHSIXdSSwsWf6v9yobREc/OQ
         hkmMki+4OIjoyVDlx/fLI5hlVaf1IPoKGLenSnXGrYEP6W4D6INWCCJVzJeXP4ISBG3y
         BQbmvdAdjEwqB19rOiUqyKvqI8Pyf/tS5GvSsYiI1qTztbgLQaGI8ZMtIrjuLvfXvhYT
         6UhQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.198 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWnpSQcBaQhoQpXu/s8Dqm30IWQ6lIv4hLWSQb92Ip3OBK9B9gG
	EgJ3URD7oXsq7/x3qmgYv6T+1O724JNkZV9rwmQjDHgIo0shKZdbRtoWOnZLosdPOhv1iark594
	F2/so1AIgprhNq9dIo6dTEGvn8xWcAFfqz/p7UQ10faZJ2xowQNrbRCjIizjvo+8=
X-Received: by 2002:a50:e619:: with SMTP id y25mr53881250edm.247.1561007180614;
        Wed, 19 Jun 2019 22:06:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybAq9ISKHAjgkcAt+Sz7t7HRs6w3mrcoIIIzK9+etuCAOxhvJxoyT5GlEiQnuZJVTh+S3x
X-Received: by 2002:a50:e619:: with SMTP id y25mr53881195edm.247.1561007179644;
        Wed, 19 Jun 2019 22:06:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561007179; cv=none;
        d=google.com; s=arc-20160816;
        b=bEaDZ5rM1AS849/QdHiEtXZIHPEGQgDegRupItCM7SwgOZhtSKxgMzIouRRnXS6ezk
         S1yeCva6zRPRDD5j3BAAgcMU7kdNTMVm1oi57vPjtKbkzYdOaqH5kewrS04BclZgLgKW
         oxVG5agJkFDlIPNHnuyumil5xW0ZofyKYMevHfD+Vcc3ROiRaNJedc24uQglCcm3sQsb
         hZiolPxcLYLqLnl/EZHQr+Vkm2I6Al/HscB833VUvES1Szis28jlr1q+7lgpDHYNvjdA
         ohdoWyyMfM1ICu6Y7cel2rgSRndGaFWj//NPDhvy5HReDdFrCrXDsHE/c7Jj/wbCryo9
         tCYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=srNjincvqY5G24pyZeONdm1hP7PP/oYRsoEsOQD60iY=;
        b=spwhDVj2tfjy4LqugDmDY4V6YJhmbbAW3qB6q5ylCy+Ceh59sqqjeWnVWqUhFePZJo
         aYOkgW7OdBKUH6zXHmAOnoNaj8lAovCsc5ukQA/GtnpV67Zuwp47MVdaVHYxO+BbBTrL
         knUgROUayizrVplFVvEaDpzV0hjrc8v+h5sSQF6IToFirz6ABp2vHHYGxiGSLX1giq8Y
         jP8N5dDza5QTEC4wth6b7+Nwz3lVLe0D0QikkR+006/YOlV80xuJ/B2Kg2O4HVZoV3KF
         4M1OLKa1fVdX3OYjiYc6L7CzIsKWGPmpBww2rObtXp0F5x9nEK4DF8IA2i1y9UwsJz8G
         nV0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.198 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay6-d.mail.gandi.net (relay6-d.mail.gandi.net. [217.70.183.198])
        by mx.google.com with ESMTPS id v4si10967063ejh.371.2019.06.19.22.06.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Jun 2019 22:06:19 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.198 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.198;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.198 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 476DCC000A;
	Thu, 20 Jun 2019 05:06:06 +0000 (UTC)
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
Subject: [PATCH RESEND 2/8] sh: Start fallback of top-down mmap at mm->mmap_base
Date: Thu, 20 Jun 2019 01:03:22 -0400
Message-Id: <20190620050328.8942-3-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190620050328.8942-1-alex@ghiti.fr>
References: <20190620050328.8942-1-alex@ghiti.fr>
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
 arch/sh/mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/sh/mm/mmap.c b/arch/sh/mm/mmap.c
index 6a1a1297baae..4c7da92473dd 100644
--- a/arch/sh/mm/mmap.c
+++ b/arch/sh/mm/mmap.c
@@ -135,7 +135,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	if (addr & ~PAGE_MASK) {
 		VM_BUG_ON(addr != -ENOMEM);
 		info.flags = 0;
-		info.low_limit = TASK_UNMAPPED_BASE;
+		info.low_limit = mm->mmap_base;
 		info.high_limit = TASK_SIZE;
 		addr = vm_unmapped_area(&info);
 	}
-- 
2.20.1

