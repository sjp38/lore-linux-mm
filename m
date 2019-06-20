Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4ADBC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:11:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90C9120B1F
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:11:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90C9120B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 373E66B0006; Thu, 20 Jun 2019 01:11:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3244C8E0002; Thu, 20 Jun 2019 01:11:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 239F58E0001; Thu, 20 Jun 2019 01:11:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CCB6A6B0006
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 01:11:18 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k15so2599123eda.6
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:11:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=30VPFryCoEsVbaJedBbFHYEdEa2oyzBbCy4so5XhB44=;
        b=EFOF565SKwThkTz0CNgucOb2bRHX4e/6xFustr4SIYIVM2Xxpw0eb8suYGENHNDAXN
         giDkqp7MzuNxznJaZPXfLvd+CtL3xbcqkZscyZZlsB5xgcBgGutTaVSuXB/lMnCZ54rG
         KXmrIZS40auQOnUnX0cPOGcvmV5VEUHsFlDi7O9QD2xWn28NOQ5eB9L0imjGbyGY7rZa
         ZYUShuGbhKJUBQDzma0U6kkPdRthqtPwKNea7G1kv69c730llYoDEuFAHTwvjJc6yiO9
         2a4zUWb8AlUBF7M+/ds2iftxS4CTAD1tqRNuFdXoJSLcfhN9QUF5MCTTw618PrOnqiQx
         AHsg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAU05YYa64b/V1wwESdUkfbY30RYnR305Xg22WI+2U/mduBJFi2F
	zb7Spj9kAH2ZsBgn3lSjktRoLxClvPcet7tig84GEUwq2+n/TLLFi2DQBVfAtbyPGe0O3olAtwq
	JXoRCWTwGjYQtc38PdGa4Fb6+E6YWM+GRgoa1g14iN45Ue4R0UGvga15h08HfovI=
X-Received: by 2002:aa7:d5cf:: with SMTP id d15mr81421138eds.67.1561007478367;
        Wed, 19 Jun 2019 22:11:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQA94YNA+PlEMbxD9VySoLd20wQdpcQYni+O/uFyelqfzmEQzolfxM14igRPyB6ENFVefF
X-Received: by 2002:aa7:d5cf:: with SMTP id d15mr81421086eds.67.1561007477648;
        Wed, 19 Jun 2019 22:11:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561007477; cv=none;
        d=google.com; s=arc-20160816;
        b=qv/Uo2NdUJKGnD8O4QkP8UnOfp2OjVbHpKK/dlsVbKXcXinTw84jhXmSSpJCBM8YMw
         MobdraRMP2UvhMDiLVxZACPYdpY/jTpV/W7qNGHbbfkAo7VK/XiyeQTtp4qC0SLXxW95
         ORLj7p6x5bxXQ69T8KT/JEL98QpJEv/KpzaxoiaeUnvifm686MEddNYp0nUYFs30PJCl
         rzKvY+l0eef2uWAdexic2Ab1Nm7RSj2kE7CkDC3VpB8l2FcuohhdDPuwMAHCjkF1ci7D
         UvV9ebq+70/UbJD7E6rcidFsFFLgsAV0+59CcfQ2SyBQZmXQQmSf0MJZmU5XU2yJOgAE
         Imzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=30VPFryCoEsVbaJedBbFHYEdEa2oyzBbCy4so5XhB44=;
        b=xMOeEVch7QzpGiHDutG7PmONtUtDP2JOr/otEF4ICm87lrEHCZkgYf43jqBCSwiJDW
         FqAQPv42KjOZChPeZf+2UPC6usa2hUPuPDuHOGeZPNCztgq9tm8c68dG0cIPbb476Bcr
         rNZS8OfVre2whz7/HJJzxbReDSiu/CZ+MXIOnrNAB7mqt/whG19qFYQSXB6emXqwhfkG
         UVHYwv5GidySMf5RZZEuyeXXKxRyF4OCaUPPSuP8dDVySRx/CCbxNvPsWddKChb5lf2H
         8PrAyz8clVWTPktpW+nMigAnM9jHSW7FPuE8T9cj33yMOGd2onhXTfnSS2EI126FnYNb
         GbpA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id z14si3816520ejq.189.2019.06.19.22.11.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Jun 2019 22:11:17 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 6AFE360006;
	Thu, 20 Jun 2019 05:10:58 +0000 (UTC)
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
Subject: [PATCH RESEND 6/8] parisc: Use mmap_base, not mmap_legacy_base, as low_limit for bottom-up mmap
Date: Thu, 20 Jun 2019 01:03:26 -0400
Message-Id: <20190620050328.8942-7-alex@ghiti.fr>
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

Bottom-up mmap scheme is used twice:

- for legacy mode, in which mmap_legacy_base and mmap_base are equal.

- in case of mmap failure in top-down mode, where there is no need to go
through the whole address space again for the bottom-up fallback: the goal
of this fallback is to find, as a last resort, space between the top-down
mmap base and the stack, which is the only place not covered by the
top-down mmap.

Then this commit removes the usage of mmap_legacy_base field from parisc
code.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/parisc/kernel/sys_parisc.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/arch/parisc/kernel/sys_parisc.c b/arch/parisc/kernel/sys_parisc.c
index 5d458a44b09c..e987f3a8eb0b 100644
--- a/arch/parisc/kernel/sys_parisc.c
+++ b/arch/parisc/kernel/sys_parisc.c
@@ -119,7 +119,7 @@ unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr,
 
 	info.flags = 0;
 	info.length = len;
-	info.low_limit = mm->mmap_legacy_base;
+	info.low_limit = mm->mmap_base;
 	info.high_limit = mmap_upper_limit(NULL);
 	info.align_mask = last_mmap ? (PAGE_MASK & (SHM_COLOUR - 1)) : 0;
 	info.align_offset = shared_align_offset(last_mmap, pgoff);
@@ -240,13 +240,11 @@ static unsigned long mmap_legacy_base(void)
  */
 void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
 {
-	mm->mmap_legacy_base = mmap_legacy_base();
-	mm->mmap_base = mmap_upper_limit(rlim_stack);
-
 	if (mmap_is_legacy()) {
-		mm->mmap_base = mm->mmap_legacy_base;
+		mm->mmap_base = mmap_legacy_base();
 		mm->get_unmapped_area = arch_get_unmapped_area;
 	} else {
+		mm->mmap_base = mmap_upper_limit(rlim_stack);
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
 	}
 }
-- 
2.20.1

