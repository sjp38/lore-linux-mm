Return-Path: <SRS0=vc3H=PU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1EC8C43444
	for <linux-mm@archiver.kernel.org>; Sat, 12 Jan 2019 11:16:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7965F20881
	for <linux-mm@archiver.kernel.org>; Sat, 12 Jan 2019 11:16:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7965F20881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85F588E0005; Sat, 12 Jan 2019 06:16:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E6728E0002; Sat, 12 Jan 2019 06:16:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 661958E0005; Sat, 12 Jan 2019 06:16:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1011A8E0002
	for <linux-mm@kvack.org>; Sat, 12 Jan 2019 06:16:38 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id w12so5828910wru.20
        for <linux-mm@kvack.org>; Sat, 12 Jan 2019 03:16:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :in-reply-to:references:from:subject:to:cc:date;
        bh=6ZxxSIUO0vInqK4qNOZ7l4Zd+cpFfWiRnJuSjl+H0V0=;
        b=JGefqbBuEnPDXdULMH7O4puus5/LuonGOOip4mZOsPQs91JUwSw7QsEpQenui1oplR
         Sk/5ZR18UlVtx8EI+SyEK1R9auBUolV3Ywsue3ktLCIurNqhgbjrwkIF6b6xauLVAAwg
         FCSMEWR0xCr/oN6DvtVDf5nRHaWUTGjZmP774u6oCxihRUTbHL/Arxruugms3MBciNlg
         09Ob1ExExhAYbIYHhXj/mjSsIqooEkNJ7d5tzuU0lmzGRtSiZDuTUpaSHOUDt01XmbhH
         M+J/2iizkoaBfnCVR/j8oxIbaLhj8vSrDaQKZtYPCmAqDuOgn/BFkeCSnjfP/+Ow7M28
         AsFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
X-Gm-Message-State: AJcUukcnoQAwnk5xY5LEiy73/CKRm90a4Urcxaui+JgTnTXzA5k6xn2J
	+bVQbjQPisZnVv4DpHc7VEOtYCBpCiJ2teMK8KMj6ilTPB1kBO1JV6RgsvcGINNjAG5pcgkE0XB
	mElA6vesqtr9ZiEcSVP9cZPAKlmZg++yzlOHRdINF80LZyj7R/ZREvSbCUSHtNrKzPg==
X-Received: by 2002:a05:6000:1c8:: with SMTP id t8mr17492084wrx.146.1547291797590;
        Sat, 12 Jan 2019 03:16:37 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4JuALQfOIIW5Duu8uauM6bWDKaqbfTiDrNmTW2nUkGWO+ZcuBD76yh9e6u6jjdjEskv/BN
X-Received: by 2002:a05:6000:1c8:: with SMTP id t8mr17492043wrx.146.1547291796724;
        Sat, 12 Jan 2019 03:16:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547291796; cv=none;
        d=google.com; s=arc-20160816;
        b=R6eQPposvi8NVxWLWMYl/kaB1V9gWPMtoiul7p5jcmu7322JDJjEUbZhIpouqlPWi0
         NgcRN9wAhnhwb82vlGEMa5z9bhGU7dqayi1qm3rPXMH40qZyyMvdRZ/MwZ0umFeaWwbo
         vPyL4n6M+H7uDrwVavOUQNpcCVFVPj263e0VKz8VFROH3AHlExm0Kr1vy1zik/UAX+3G
         Bt+51NtXvdEzUYvhcBUQXR5UYLrAC7DfA35hpDO4n1tqk+23VvZTjshbXQLP0oIURir1
         DBP09tBUUcOBqn0zJbA9UoxWmrmAL/dz3kvf7pw0CIpGxml1fh7KlHphhLH/kN3vVvNv
         KfYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id;
        bh=6ZxxSIUO0vInqK4qNOZ7l4Zd+cpFfWiRnJuSjl+H0V0=;
        b=y2q6iNT0Zz1+lZdssIOhl/ue5EqAVIt5+GNCLieJn4pkgKzU3v+6tDpnYWorGtexPS
         MDrPFEFI6qELgs9JQYoSn5BS6HmDsvgDjOpir8qKTNfReTAWbgt+7WiODkQbssGkXTmu
         xDNsXQfIpO50OBtZ3bMH+/hH9aHNZRspm2Biv5xrjlKqYhJHSVcqbD05W+fD2PzhGHze
         3WCtzD4hSN1B4STZ3Y01Ypa80BiciKUR7cGqF8JP0W115h1qWj70Vuq7hMWuDXAm2TLn
         roTct/c3gWtsXSLSdSjVd/OZQsjsgVZFU97TVBrMHJwBzvAzu88uzOd4+EUbP+F5iXgI
         sc0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id p4si45685334wrh.452.2019.01.12.03.16.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 Jan 2019 03:16:36 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 43cHHP2LVmz9vBKB;
	Sat, 12 Jan 2019 12:16:33 +0100 (CET)
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id E5fglM_aPN3o; Sat, 12 Jan 2019 12:16:33 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 43cHHP1h85z9vBJm;
	Sat, 12 Jan 2019 12:16:33 +0100 (CET)
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 2BF848B77F;
	Sat, 12 Jan 2019 12:16:36 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id EkBd4dfpxvhw; Sat, 12 Jan 2019 12:16:36 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id F10C38B74C;
	Sat, 12 Jan 2019 12:16:35 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id CA18B717D8; Sat, 12 Jan 2019 11:16:35 +0000 (UTC)
Message-Id:
 <0c854dd6b110ac2b81ef1681f6e097f59f84af8b.1547289808.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1547289808.git.christophe.leroy@c-s.fr>
References: <cover.1547289808.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v3 1/3] powerpc/mm: prepare kernel for KAsan on PPC32
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, 
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Sat, 12 Jan 2019 11:16:35 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190112111635.Cj3Z6Zjgkzj_Gdd5jQV3rMLKbKC960tvwk0RrlCJgsk@z>

In kernel/cputable.c, explicitly use memcpy() in order
to allow GCC to replace it with __memcpy() when KASAN is
selected.

Since commit 400c47d81ca38 ("powerpc32: memset: only use dcbz once cache is
enabled"), memset() can be used before activation of the cache,
so no need to use memset_io() for zeroing the BSS.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/cputable.c | 4 ++--
 arch/powerpc/kernel/setup_32.c | 6 ++----
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/arch/powerpc/kernel/cputable.c b/arch/powerpc/kernel/cputable.c
index 1eab54bc6ee9..84814c8d1bcb 100644
--- a/arch/powerpc/kernel/cputable.c
+++ b/arch/powerpc/kernel/cputable.c
@@ -2147,7 +2147,7 @@ void __init set_cur_cpu_spec(struct cpu_spec *s)
 	struct cpu_spec *t = &the_cpu_spec;
 
 	t = PTRRELOC(t);
-	*t = *s;
+	memcpy(t, s, sizeof(*t));
 
 	*PTRRELOC(&cur_cpu_spec) = &the_cpu_spec;
 }
@@ -2162,7 +2162,7 @@ static struct cpu_spec * __init setup_cpu_spec(unsigned long offset,
 	old = *t;
 
 	/* Copy everything, then do fixups */
-	*t = *s;
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

