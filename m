Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05362C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:23:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADD47206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:23:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="sXNJ1RJy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADD47206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 281F46B000C; Fri, 26 Apr 2019 12:23:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 231D96B000D; Fri, 26 Apr 2019 12:23:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 14AF56B000E; Fri, 26 Apr 2019 12:23:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9E92F6B000C
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 12:23:31 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id x1so3851995wrd.15
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 09:23:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=ctAbUIG29RjpHeVTI4ljbxurfZcpTtykFHhM/QW4LDg=;
        b=DSnMGO4cjtcVxBsjnxFuz0jSTb8LwA4l3XIOmmiSWUFdnl4WaDSJ9Sj813AYSXZwOL
         gselv3fI9re2Ms6nxX9Bnu9a6Xf0hXbNMJ2N7I/pYlWAi/G3JfmY0tjyecF10oMtlfg7
         8kRjeOMQZRwd4IMxBXWeQQn8sRU890/tzUY4zo2W6FbftXh+4/MhpvMvReZByQfVgo7z
         x2mFk+c3BE56u41olQl4vsPQHVSNGtFqc9s7XcWbMxCyQOsRutVvcHU602swOjcLfxgb
         yl0761oLuNGcVj7WLQxn9c/EDpNYL9xwgW6kOpr6qNJAFz/d6rXv2a9Qmtle1DZ10zyx
         NJkQ==
X-Gm-Message-State: APjAAAWMsJN/2G/IwMiY6Yybnh2U8qlAL6/b2XKSngJFtyZ5TuW/99bx
	FwHR3MErpj7WHaZ2gW1vVGSu/NHQH4nj/D46Prwu881ehO+IMx+vcUqHUirIW9TW3YcDLy7jXf9
	4ZpQWXtTbExhRJeiKikueB5GSsPd2IIq6LbacF9LfccyNwFVoYJ9Mwh/72mFQnzycDQ==
X-Received: by 2002:a1c:f719:: with SMTP id v25mr8599693wmh.90.1556295811173;
        Fri, 26 Apr 2019 09:23:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2Sucs7rlVJ2DQ9V2OSsqZzddo9n0R9c4ukav20d+Cbw674vluaB1BaeDqswCXvrvUvF0l
X-Received: by 2002:a1c:f719:: with SMTP id v25mr8599624wmh.90.1556295810190;
        Fri, 26 Apr 2019 09:23:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556295810; cv=none;
        d=google.com; s=arc-20160816;
        b=DiIj9oyeygt6haR88DtNcZ/AuhU5BMhhT/m2Yztfi9YWSUp5VKAd03R5UWGPOMoYbk
         AQUPFQETgxolx7RSK0IEzhX393jKbxIpTtupq4R1ce79BBdOAQDAhCslCCYl4Aun6zmN
         1LiiAW4ViqlvSJawDyOyNiHxFFDlW8MEZK9WM7SOdUC77ZWo6hUkXQffGv6p27w/42pq
         o6Wx/1zd6NASIvZ5yjrHk6y/RHQ3I2LcA9KlEc3sCHA1W39jV/1NTbhAfGE+SFaJM2Iv
         jvIvHpd7YYXkI8/VA4/YpnwynE7hihpC6B5jMlMfiQzCDukzFR1oU1YcHN40uMcGop35
         p20Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=ctAbUIG29RjpHeVTI4ljbxurfZcpTtykFHhM/QW4LDg=;
        b=OSdKjgKM+gvw41KAXWi2IPnIEdukecsfCajH8cJavQMruJw6woOQIeH5N6mcT/6dye
         7Lm9BsiO3Bo99xDXoaoaLSSxT6KJE/uL4ZnHmBveFHWeEIsaz6Sdd+oAiXqLuYcfzm/c
         UgncGgea+AmJh0mIhQv7l5PmNvAnk3CzGEPsrPAlZSYHxNvduAtGXqmiXlk1eMy/FqVE
         EYHk7vlIzh2NMKaD/5yZu6n7Qo73+EqoxyMElPNdH6BiZiMpRsCKQvafN47IyKDrqO9D
         gyDxTlYon+cJrvkb1wKieeCVNIJ7LuW6klGDa+hnrKx97S+ZoJJSu3bAxlBIYq59Y6zF
         M1Ag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=sXNJ1RJy;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id 188si17841865wme.63.2019.04.26.09.23.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 09:23:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=sXNJ1RJy;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44rK9X08lbz9v0yq;
	Fri, 26 Apr 2019 18:23:28 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=sXNJ1RJy; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id gOIgGEDQnVcg; Fri, 26 Apr 2019 18:23:27 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44rK9W6BZ7z9v0yk;
	Fri, 26 Apr 2019 18:23:27 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1556295807; bh=ctAbUIG29RjpHeVTI4ljbxurfZcpTtykFHhM/QW4LDg=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=sXNJ1RJySc1t5BpAT+oYpyRRDpip0+eueVBMTRrcWzig9N0oMfAE7RJ7tqS1Geyh7
	 mAlPR78drX1AT85Ic0cvroaN9YdvdREP0+V4+v66Sk/aESCTYcKoOMUJgsv2pifpxD
	 WU/ztu/E9EETgZbKRpnRDHg0QAjhk6G7Xe7TeIQE=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 873518B950;
	Fri, 26 Apr 2019 18:23:29 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id OIc1Ih9pEinJ; Fri, 26 Apr 2019 18:23:29 +0200 (CEST)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.6])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 697DE8B82F;
	Fri, 26 Apr 2019 18:23:29 +0200 (CEST)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 5BBA2666FE; Fri, 26 Apr 2019 16:23:29 +0000 (UTC)
Message-Id: <7f4aad95264a69d9e278845a31a63f323b498fdf.1556295460.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1556295459.git.christophe.leroy@c-s.fr>
References: <cover.1556295459.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v11 05/13] powerpc: don't use direct assignation during early
 boot.
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri, 26 Apr 2019 16:23:29 +0000 (UTC)
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
 arch/powerpc/kernel/cputable.c  | 13 ++++++++++---
 arch/powerpc/kernel/prom_init.c | 10 ++++++++--
 2 files changed, 18 insertions(+), 5 deletions(-)

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
diff --git a/arch/powerpc/kernel/prom_init.c b/arch/powerpc/kernel/prom_init.c
index 7017156168e8..d3b0d543d924 100644
--- a/arch/powerpc/kernel/prom_init.c
+++ b/arch/powerpc/kernel/prom_init.c
@@ -1264,8 +1264,14 @@ static void __init prom_check_platform_support(void)
 	int prop_len = prom_getproplen(prom.chosen,
 				       "ibm,arch-vec-5-platform-support");
 
-	/* First copy the architecture vec template */
-	ibm_architecture_vec = ibm_architecture_vec_template;
+	/*
+	 * First copy the architecture vec template
+	 *
+	 * use memcpy() instead of *vec = *vec_template so that GCC replaces it
+	 * by __memcpy() when KASAN is active
+	 */
+	memcpy(&ibm_architecture_vec, &ibm_architecture_vec_template,
+	       sizeof(ibm_architecture_vec));
 
 	if (prop_len > 1) {
 		int i;
-- 
2.13.3

