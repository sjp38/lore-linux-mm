Return-Path: <SRS0=7n0b=P6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 525C5C282C3
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 14:28:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F8E62054F
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 14:28:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="Ul2csKib"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F8E62054F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39CD58E0004; Tue, 22 Jan 2019 09:28:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FF7A8E0001; Tue, 22 Jan 2019 09:28:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C38E8E0004; Tue, 22 Jan 2019 09:28:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id BA6F48E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 09:28:51 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id h11so12563989wrs.2
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 06:28:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=um9yCYwOJ1SkZMPifhMErWXIPjN8RMbQWLCsWKAg55E=;
        b=pNz+bnjwSj6OrkrqGR3c1xQTj1DVQuBFnc7ZkCGIBnuNIt0HHSuIMQ24aQZxnH7BNn
         PUy0x1glRIf98Snp+CKhVnqUPJikHtDOM0LzA4vDAKQl/lQXyBTZE6e+FPteS3rETvi0
         F/QmNd5Sv10YBgyutv7m589AApFxWW1Ln/mr4lO1RMrLgDe6rUQHVdsS20lU/JWWE3SW
         B2jYN60RvbOvWNQxz1+1a+G+mQ72yMe5pckUaH2BLtxzRB64ymBQKcv4m+kTzDW3F7X6
         NtCRZv/sCB12CEkHZoOkF2N46n5bXmXw4kr1EXzVkRWVIdXWTJcpeOuHhX+5T/+rzolX
         zlvw==
X-Gm-Message-State: AJcUukcEOBQHDabDkcXv6GfOsnd11lBe8vbCfNtYWPZUbosb1jlC0hHQ
	AcE5miTo9bxUeE7L5dMFNbHxR3nHEBhiJGtTqxNEbRdYCssfvu1GdBkvM7JTDHWLb9lARKhXPxT
	E3n0Eai94myEh8sOFAk7Cd5YmjpnRUM6PQVZIeVb/VQJNSdlGWaRh6CmChUDwzbS49g==
X-Received: by 2002:a5d:44d1:: with SMTP id z17mr32171442wrr.271.1548167331286;
        Tue, 22 Jan 2019 06:28:51 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4WiwZVXwXysQzjUIqq4fb8dtbGiqyIwnArk3L9s7L5yohN7zc0ztnrrj+ZKujmfugVkQWk
X-Received: by 2002:a5d:44d1:: with SMTP id z17mr32171365wrr.271.1548167330090;
        Tue, 22 Jan 2019 06:28:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548167330; cv=none;
        d=google.com; s=arc-20160816;
        b=MBgbwkZjJlAXjNo4cH+ubVXhj0SBPFW2BrLh+Q6ED9WsxbAquelPb3vkOTnbsYcfGl
         YNdmWE8P6tVqHldlenDkYyFbrYKVoO+1PYYttzT2M798b0Czs3/w4gE6wutwElOJduL8
         itjQGMlosunlb+Znj95b5qHy4oagqwmqIcWz1ISbMfLkI4q72/z5256CR0NFpQvtgovy
         5awG7gRoE7RbEEfQnK7/I1J72KeKG7/DlI3Qqi1PK+AU/B5xxZhHdcq4Oa7Ib72pepwf
         dxjIm3lofvPBqjsOiEMyitvZQHPmbjzcO3rSndTenPqN0siXj6S8/F/0cCh7gNa5ATma
         ZnSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=um9yCYwOJ1SkZMPifhMErWXIPjN8RMbQWLCsWKAg55E=;
        b=ZrtRtVUYhyTfwpMohhiuEkHz2D9ddGHBIRncZCrKhPhWt+5d3cewxOh7pYl6hhR80c
         azgGbGIxIwlc2cuTwFP/6wVWqSTaYegVxrQfw9aGsP0G549tSlVD7MySSKKrS6/vQbpD
         HohPwAcRwS6d+gdQEczRtAMzrcE1jRJTlF4R3Zs17QXlH0eaeC/Be8QHcx6o8R9lZSfn
         bhI6/jasOty3Q42oDUlGBCIRe/lv7p6zRhtkxnDPgOxNslGCIYXKhnuomlG4eKXZax5y
         d7xgXDUMDLgYXxgqFVpySNvr9zCj2Z/CAow/ROVfekgRmcqvCJq95au6M3cGxF7P+Gtj
         H4gw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=Ul2csKib;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id u187si34161188wmu.42.2019.01.22.06.28.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 06:28:50 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=Ul2csKib;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 43kW4c0kSnz9txr4;
	Tue, 22 Jan 2019 15:28:48 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=Ul2csKib; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id fo5JjB4w2Uh6; Tue, 22 Jan 2019 15:28:48 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 43kW4b6m5Wz9txqk;
	Tue, 22 Jan 2019 15:28:47 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1548167327; bh=um9yCYwOJ1SkZMPifhMErWXIPjN8RMbQWLCsWKAg55E=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=Ul2csKibFGbmGJtOtYND9MSafLFN9wzj1IsLa6KvwcahTXZ8nqvLL4LSM77v4Rijx
	 cH1TbyYqtK47fuiDkQkugVMKH3lIB/vsPjQFVqVLlmDipbE9Zx65TE1gWuTyilaP5O
	 cHDjPCZIUJR9iyNHu7RrfdMpBxJMS1K/XktkRID0=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 55D1B8B7E9;
	Tue, 22 Jan 2019 15:28:49 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id LyO9M-yhUETy; Tue, 22 Jan 2019 15:28:49 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 250168B7CE;
	Tue, 22 Jan 2019 15:28:49 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 5235B717D8; Tue, 22 Jan 2019 14:28:42 +0000 (UTC)
Message-Id:
 <860cfdb1aa5aa580f87cd14e4a7df2f315c69357.1548166824.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1548166824.git.christophe.leroy@c-s.fr>
References: <cover.1548166824.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v4 1/3] powerpc/mm: prepare kernel for KAsan on PPC32
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, 
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 22 Jan 2019 14:28:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190122142842.chomV3dszYXEuUQH6GXBUa8PoHV6rleyZkrBCOgyN9Q@z>

In kernel/cputable.c, explicitly use memcpy() in order
to allow GCC to replace it with __memcpy() when KASAN is
selected.

Since commit 400c47d81ca38 ("powerpc32: memset: only use dcbz once cache is
enabled"), memset() can be used before activation of the cache,
so no need to use memset_io() for zeroing the BSS.

Acked-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/cputable.c | 13 ++++++++++---
 arch/powerpc/kernel/setup_32.c |  6 ++----
 2 files changed, 12 insertions(+), 7 deletions(-)

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
diff --git a/arch/powerpc/kernel/setup_32.c b/arch/powerpc/kernel/setup_32.c
index 947f904688b0..5e761eb16a6d 100644
--- a/arch/powerpc/kernel/setup_32.c
+++ b/arch/powerpc/kernel/setup_32.c
@@ -73,10 +73,8 @@ notrace unsigned long __init early_init(unsigned long dt_ptr)
 {
 	unsigned long offset = reloc_offset();
 
-	/* First zero the BSS -- use memset_io, some platforms don't have
-	 * caches on yet */
-	memset_io((void __iomem *)PTRRELOC(&__bss_start), 0,
-			__bss_stop - __bss_start);
+	/* First zero the BSS */
+	memset(PTRRELOC(&__bss_start), 0, __bss_stop - __bss_start);
 
 	/*
 	 * Identify the CPU type and fix up code sections
-- 
2.13.3

