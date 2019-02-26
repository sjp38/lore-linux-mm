Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED0CCC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:22:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA7CD21848
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:22:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="ti1gVhxy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA7CD21848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80B6F8E0007; Tue, 26 Feb 2019 12:22:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 740898E0003; Tue, 26 Feb 2019 12:22:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BB048E0007; Tue, 26 Feb 2019 12:22:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id F1FF08E0003
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:22:47 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id t133so710534wmg.4
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:22:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=g6fhwCUzzCOYhxsR7m9Lo9kcYtSGDH5kmO2yLp27uXY=;
        b=VYkyFY7n6fvApIBGBaUbhqc42HFsAhBl/CogJ2QgUG8PyAOLLi8Bu9z3nm5K87fOj6
         1IPd+GC/1MPAhFcUqCk532L8n/EkI8pGYU5L3QV7t+j9gs8dRR4MHVWbY6WXO14WEXxI
         ucbjxF+nnE12uvSSLKryn80uwouNOizIKku5otGBR0sm9sSJBgAZ3Kiq9PN+my6XEFnn
         LLh0QMzZ6uBORWwbZRe9iHRtUXyHFEWYqNOfhxPvLS0ec+lZfcST2VreWmfit4BVmXJ3
         0mM4IEdvugQ0Fk8GQ++07tw0r3vaeZ3e2zq7nfV7x8SZ23kKFM3MtmsbpdA0HQN0XIHJ
         +UUg==
X-Gm-Message-State: AHQUAuZVAGep+QMWqtBuPHvpeXlmsG6viE/rVj/ESqLlrdAl3ExA448o
	p84E9BK8M6Ty0iZQLc2Wjbkvouhkj2W9CU4W0zpcb3itSwjYHsfXzWTzv1UVTG9nE3KdLi2mxw4
	dZYByAcc36xC1tov9Fklqp7LHTok8EGjx44FyHxaZ3TpBTQFHh3KiwC7Lh1rJ9XC78Q==
X-Received: by 2002:a1c:2743:: with SMTP id n64mr3585958wmn.143.1551201767518;
        Tue, 26 Feb 2019 09:22:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYmY5HTOgDtqV1Pp+0wp9qiwxuSaffaQ9yk6IaKGAfgqMmogN0XakajTrsCJhttuaBSx2q6
X-Received: by 2002:a1c:2743:: with SMTP id n64mr3585911wmn.143.1551201766390;
        Tue, 26 Feb 2019 09:22:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551201766; cv=none;
        d=google.com; s=arc-20160816;
        b=PsqfBV/mrZJsUZJPcNzetyd4WaKXkwRmb+uaYXcG+ga7d20boQ7D9i9YKm8fWNn5EL
         k3e/HcOnVpkTfpHkYjo/q7OpP/gMJAd4Jbz8d8jWcR8VlBuXjevfqLUvvAcLoxk4HFu9
         X81hZ9bulkvHlLlUUxsqNf94CJXc9LWyy7Gbe/6NK6fJSpgrnBCRw+RyioEXIzaazhhu
         T/OI6Q+MAoZZ4KGcogpQ3qfT2I/5wDYtWbCDtpZDvt7BGu13sryOrXdNcJs7SSaq09Wc
         WBMlSU71zjX1C/ALwMwn56yjw3nMPyFtEmmxJdMOjbhwg010g7mLO9nMIzdrLtoUFsfa
         cLWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=g6fhwCUzzCOYhxsR7m9Lo9kcYtSGDH5kmO2yLp27uXY=;
        b=i7diXIKNoqbtHdXF3TM/D7kb41huraktdrGn3cLjQwBMnlyv5jpE94EkxbNAcwhFhq
         JIbxm/zsetZ44eILZ6sHSmQdDw5Lfff1GXQqBRvJ4mKkQiFiUDWEXEOI6lKbMiyvfXEF
         Mf2J0yXUQ/GCl6wcs6bYVsRY2AY2u0VlZD7zvoEKFLlSsMMBGGQqgEiH82EWn1erEQcO
         2H1DQlferDo4kshEaUsw06NnCZmtYlJO4zgL0+g7JUHybtlu9ukCke+ppkC+kjhTP2ao
         /ZTdHcFsShuq8H7XZas7Hj8ngAO5CZzJM0PYDwgu+LYV2ax8TbnXdBkY31ITfbjCDGOg
         iCzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=ti1gVhxy;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id h65si9035506wmg.67.2019.02.26.09.22.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 09:22:46 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=ti1gVhxy;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 4485H81cRnz9vJLf;
	Tue, 26 Feb 2019 18:22:44 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=ti1gVhxy; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id YOx664-dutKR; Tue, 26 Feb 2019 18:22:44 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 4485H80QF9z9vJLY;
	Tue, 26 Feb 2019 18:22:44 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551201764; bh=g6fhwCUzzCOYhxsR7m9Lo9kcYtSGDH5kmO2yLp27uXY=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=ti1gVhxyHR1EvrNdR4KPf3SZ+OfMqvO5xQo4KDWAttWKHQctabiTkPCjAmwXBDInv
	 43t2J8BJYVHmrr1aVPUuxFMair+woIM74TbrxfjfUGnjIuy7vWaDCmnC+GeNapRCx+
	 1/aq0Z4u+d8SVSJtWwtfNNE30GRtJLC6KEwtHst0=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A87DD8B97A;
	Tue, 26 Feb 2019 18:22:45 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id wssN5870d0AG; Tue, 26 Feb 2019 18:22:45 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 6DBB28B96A;
	Tue, 26 Feb 2019 18:22:45 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 4DA666F7B5; Tue, 26 Feb 2019 17:22:45 +0000 (UTC)
Message-Id: <a4b9dd8f9cd353dbe56ba08a6128de7b81417d01.1551161392.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551161392.git.christophe.leroy@c-s.fr>
References: <cover.1551161392.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v8 04/11] powerpc/mm: don't use direct assignation during
 early boot.
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 26 Feb 2019 17:22:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In kernel/cputable.c, explicitly use memcpy() instead of *y = *x;
This will allow GCC to replace it with __memcpy() when KASAN is
selected.

Acked-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/cputable.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/kernel/cputable.c b/arch/powerpc/kernel/cputable.c
index 1eab54bc6ee9..cd12f362b61f 100644
--- a/arch/powerpc/kernel/cputable.c
+++ b/arch/powerpc/kernel/cputable.c
@@ -2147,7 +2147,11 @@ void __init set_cur_cpu_spec(struct cpu_spec *s)
 	struct cpu_spec *t = &the_cpu_spec;
 
 	t = PTRRELOC(t);
-	*t = *s;
+	/*
+	 * use memcpy() instead of *t = *s so that GCC replaces it
+	 * by __memcpy() when KASAN is active
+	 */
+	memcpy(t, s, sizeof(*t));
 
 	*PTRRELOC(&cur_cpu_spec) = &the_cpu_spec;
 }
@@ -2161,8 +2165,11 @@ static struct cpu_spec * __init setup_cpu_spec(unsigned long offset,
 	t = PTRRELOC(t);
 	old = *t;
 
-	/* Copy everything, then do fixups */
-	*t = *s;
+	/*
+	 * Copy everything, then do fixups. Use memcpy() instead of *t = *s
+	 * so that GCC replaces it by __memcpy() when KASAN is active
+	 */
+	memcpy(t, s, sizeof(*t));
 
 	/*
 	 * If we are overriding a previous value derived from the real
-- 
2.13.3

