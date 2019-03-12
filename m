Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0194AC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CAB7213A2
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="GRISycul"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CAB7213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8391A8E0009; Tue, 12 Mar 2019 18:16:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BFBA8E0008; Tue, 12 Mar 2019 18:16:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DC888E0009; Tue, 12 Mar 2019 18:16:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id E05398E0006
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:16:14 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id t190so1030502wmt.8
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:16:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=g6fhwCUzzCOYhxsR7m9Lo9kcYtSGDH5kmO2yLp27uXY=;
        b=fKL+UKPaitcoSgVb78pnXq5PUuSc0UcQnHigh90xF1fq5+7USyhC5XutkuLd4LA3ON
         o4pAKw+IdQXQkxtiMaFzC6+s6+K1j6gVqCgnfTGoPKWPiGsrI+cso4GOFLOpsGNqC7Q8
         pQ45l8y1vgSLpd9X3j/j1eSQujzAnz3W9FezfYQIUwRDHX8gxsXzZE+22ATqjoEGLnZD
         4bvK1OQMFvxoJVBHZwAEjfpo3Y0L8uvMmxcv1bnj7KshE+lJMwDSKXnWactOliICWNvk
         9VcJaHGDhzEO/etABx73UaTJeCrrGCiGVW6TgC+2e8PRtqAjFTi4cf5VaKdgvULGyPzD
         Gq1w==
X-Gm-Message-State: APjAAAUYJyNslkIKFfWgp+ESyxdTVB8uxyEQFF0rzIodxnTSK78+zo4B
	xAUxgFDhWrUG+evWY7nNDnDY6hZ18Lmvu1NusTfojcjSWgpdb9t7+HkHX5GY5oRVpkJNIZOUVu6
	CvufjO7o+c7iHyWuPOZoOaZI/TGR2UZCy7ldVg2pYFy5RaSVYncOlls3jIAcCwKdXvg==
X-Received: by 2002:a5d:6b4a:: with SMTP id x10mr3970145wrw.63.1552428974097;
        Tue, 12 Mar 2019 15:16:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwINzhfZ0wJnnjlqHRwQBWJDE5V4RqROJR+XRTnWassmRtOahwIE8OnoMwOdN0pHIP8g4A5
X-Received: by 2002:a5d:6b4a:: with SMTP id x10mr3970124wrw.63.1552428972929;
        Tue, 12 Mar 2019 15:16:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552428972; cv=none;
        d=google.com; s=arc-20160816;
        b=U9lP6mdjKg3+JTV9sICR9hmdNKBROyE550kYBajVW2Sp/vVOG+2hrGUz4IQw8aGNNI
         W6pNHwn0bp5K5A4KNm1s5ORfvPciPFwvKE1uXTQfF02h1ZcHjD/ass2mKieGMlPUScwe
         ViXg+Jtq0tsAdy5GXXNrhFlOApLQq0hGd1VCReNVbWO9zJY7sxxHMSnn9KGGKiBHm7aJ
         wykYs3YMpYRIOv4X0MZmlX591nUX7PtfmUm6cDLNiwYIJ/JO5Ex0WKPRcoJXMZqlUDU9
         5jQx93ZXyvZWXMRNymfkApXk8J7hNipJX4c/HuQ49nnSNVjTWTaYn/xRcoqcPF2lmhhl
         EiOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=g6fhwCUzzCOYhxsR7m9Lo9kcYtSGDH5kmO2yLp27uXY=;
        b=eYBGLiCIoXa7vgmBwqFCxYJxBoBE7rxRqP6qk4jF05qrHCoOo7Nx0brYzxqBdg1Qyz
         ohTe2suoRgy1awtRkb9DQmpupe35vtdTsnbX+ybnvTY2ihPJBPFnWaCG0QlOVwbcfd0D
         oQ2hLqj1viL72yrQkuTGwTuuatxtin/FplqqfUju9avFiMRi+IqBQpmD4LOcfqG8IQFt
         avbrD9qJRzesI4G6gV2d6COp6SUGMzcBt4aFGApje4RCOx6CBh3obAvBIUyETsunlFNg
         8f0A3+2pQaBfeTm6uHyGan+CDVyIAheRPDPPIP+x1L0LCy+XB6NGAYq5t+Xnra1pDh5h
         fC+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=GRISycul;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id n4si6752767wrv.441.2019.03.12.15.16.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 15:16:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=GRISycul;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44Jq7J1NQSzB09Zk;
	Tue, 12 Mar 2019 23:16:12 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=GRISycul; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id W60iEXBdWSrt; Tue, 12 Mar 2019 23:16:12 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44Jq7H6y2JzB09ZG;
	Tue, 12 Mar 2019 23:16:11 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1552428972; bh=g6fhwCUzzCOYhxsR7m9Lo9kcYtSGDH5kmO2yLp27uXY=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=GRISyculWuNgpnsKVSDrLXiB3Vx7W9rFI3Jlby7Ft1rk8XgMyJxYIBcneemW5ut8W
	 arFKEhEtOFE06YUwRz9MjH8s+X0MRv/qV4lKwTUPQsTTEhWwSxRRueOP3N0mPyyQJL
	 nPNgPBBuLQySI9YEaaw6KAoItz6ppObJkgmsG2B0=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 31E378B8B1;
	Tue, 12 Mar 2019 23:16:12 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id oybGxBwVbTKv; Tue, 12 Mar 2019 23:16:12 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 0577A8B8A7;
	Tue, 12 Mar 2019 23:16:12 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id C0B646FA15; Tue, 12 Mar 2019 22:16:11 +0000 (UTC)
Message-Id: <f025c7da8723e5392843e06a5bf00a447db014c2.1552428161.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1552428161.git.christophe.leroy@c-s.fr>
References: <cover.1552428161.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v10 06/18] powerpc/mm: don't use direct assignation during
 early boot.
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 12 Mar 2019 22:16:11 +0000 (UTC)
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

