Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA194C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:23:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A94FF2083B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:23:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="DeIcy5m6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A94FF2083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A8708E0002; Tue, 19 Feb 2019 12:23:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7079F8E0008; Tue, 19 Feb 2019 12:23:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A9C08E0002; Tue, 19 Feb 2019 12:23:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id F3AB78E0008
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:23:18 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id q126so970561wme.7
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 09:23:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=RqJsxIhTANQKnqRZhq3GM2+DKQlwq3Vr2BGgpdQ32hQ=;
        b=ZzMV+oUHrMfvQi4SVuw7RPRUYdngYI+5FAjwmCnYnp1khFnzfvyFzDmP0Gm+2Pc6ad
         m1Jn7QnBBwHPz4rlPSHr5pY/kchWAUayzgoKqdbI5fGGmxHcYGgYEKmVMpwMccG4oriN
         04ht0bX0K9T9zxkwQ/BHjMciddl4OI6jy2KbPAv1+iWBNoUKwJJI0UFyMvxPVM8Fvl+d
         /MCpQ54tg9TilEcuYMtPE+5nkh31pA301Nnd2k/53QsvrrdpVetfL5u6LXkWwN8kQQXF
         f0ymRd6rcnF7sE/Pk/EfY/Uc99tNaTgN3qnGE8E7YSGX7UASjLnqkt57oEIZRJLoO8ig
         qmSA==
X-Gm-Message-State: AHQUAuaPqtDXBm09j3gOwC5A7BXyUzjoqnUe6lwhsbTVF9eVFcA5vRVA
	YL2AFHLSoe/3q3gpmwbynsxSEpnigAJyp7J1WYZUzmk/ZefZ4u21x/vS6jeOAZQNI7/93pzFGSc
	q0kzFkKCQ27AwQ5ClgqgoWt56qRU/A2K+JGqC/j6G00YNYgvmZu4lrOZlBZCaLacu1g==
X-Received: by 2002:a1c:7511:: with SMTP id o17mr3559824wmc.42.1550596998499;
        Tue, 19 Feb 2019 09:23:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZCqUe91RsuhoZ635R0k7KRV2tzLJzL6xBKUqYmf/W3D+UwEn11cTeg272zwY94abgJtuiz
X-Received: by 2002:a1c:7511:: with SMTP id o17mr3559775wmc.42.1550596997493;
        Tue, 19 Feb 2019 09:23:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550596997; cv=none;
        d=google.com; s=arc-20160816;
        b=EOnwA4r/++ecA0HOahs75Q+ooAp1ckIx2L3+5VAMqQanpbTt1/XBTc7xjdxZ76bDde
         4vl7JIHg5rjtGixXLAi4TjWdBVep1N4NbgcIcLHGylPkCk2joCVArPvrDlBGsuT2IC90
         S0SpGUXN/TrkeCMTE8wz2D3zDjgsW1wg/ETYuvu8lBRjEvSyVkszA37r0DfKfE7B5tv3
         9gwKwD9IxUP7KP5T0B0JcmWiDakfqDcZUi9i6iBD1oneLh2bPSCAvqOMmpqINP5Vp95n
         IBSUnCQ1Iof2vnSwUyDN6kNri3ogZm4ThHDzcsLnguHvt08eXsS0SuQxYl8IL4XIrgaa
         nkww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=RqJsxIhTANQKnqRZhq3GM2+DKQlwq3Vr2BGgpdQ32hQ=;
        b=T7bcTcvsuc0EA17RHj4L4uEqP3KjL8FppQPJkTBG4u+l3TOHIPCUxYvOOV86xtARIO
         GN+V4bCpnrqIpbYxIm79QhioLqlOTwWiOkMEzq0IuvyWPNm+obRFkAX8EE5wA+zPMZU9
         vsncMkz8wXkkrwtgyrrhXwLwgWBMVKpOlF1nikK03gLgh13pFMGFr1+FpLoa44dbiuqT
         yzsvnGXbYr8Gj9q3d8AiumoBt0eqsM7gCkWZ3VQJfof+bVQNquPkSIGUxMVA0US7Wl0D
         l7ov9cClqd65CdGdc0e0FYLbnh1oV9dyCfKBDQ5JMX/NACgxuQg1fz5vskWbdR09KkQj
         vhLg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=DeIcy5m6;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id p185si1868763wme.188.2019.02.19.09.23.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 09:23:17 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=DeIcy5m6;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 443ncz2CDBz9v4wg;
	Tue, 19 Feb 2019 18:23:15 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=DeIcy5m6; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id CpEQ0pBH1KSX; Tue, 19 Feb 2019 18:23:15 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 443ncz12hqz9v4wf;
	Tue, 19 Feb 2019 18:23:15 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1550596995; bh=RqJsxIhTANQKnqRZhq3GM2+DKQlwq3Vr2BGgpdQ32hQ=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=DeIcy5m6M9wZSKEodSFq/7LxoFd+RwflVuC7e9pIaf5A4sLTdV+IovFCpLtsjQACt
	 loLCSLdw72urjv816h9J4pZK1G1ePq00eTG5KUdOWNc200bArr6smG9T8/IY8q4Ley
	 PhbLP/uxG1CE95fSdKO7k6PvHs/jTgd9H/ZB6eQo=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id C10178B7FE;
	Tue, 19 Feb 2019 18:23:16 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id ZTiqLc4V9f7e; Tue, 19 Feb 2019 18:23:16 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 913578B7F9;
	Tue, 19 Feb 2019 18:23:16 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 6E4BF6E81D; Tue, 19 Feb 2019 17:23:16 +0000 (UTC)
Message-Id: <7f8dfeeb13b54f9518f78d9c8550a3769d144fc3.1550596242.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1550596242.git.christophe.leroy@c-s.fr>
References: <cover.1550596242.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v6 5/6] kasan: allow architectures to provide an outline
 readiness check
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 19 Feb 2019 17:23:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Daniel Axtens <dja@axtens.net>

In powerpc (as I understand it), we spend a lot of time in boot
running in real mode before MMU paging is initalised. During
this time we call a lot of generic code, including printk(). If
we try to access the shadow region during this time, things fail.

My attempts to move early init before the first printk have not
been successful. (Both previous RFCs for ppc64 - by 2 different
people - have needed this trick too!)

So, allow architectures to define a kasan_arch_is_ready()
hook that bails out of check_memory_region_inline() unless the
arch has done all of the init.

Link: https://lore.kernel.org/patchwork/patch/592820/ # ppc64 hash series
Link: https://patchwork.ozlabs.org/patch/795211/      # ppc radix series
Originally-by: Balbir Singh <bsingharora@gmail.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Daniel Axtens <dja@axtens.net>
[check_return_arch_not_ready() ==> static inline kasan_arch_is_ready()]
Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 include/linux/kasan.h | 4 ++++
 mm/kasan/generic.c    | 3 +++
 2 files changed, 7 insertions(+)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index b40ea104dd36..b91c40af9f31 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -14,6 +14,10 @@ struct task_struct;
 #include <asm/kasan.h>
 #include <asm/pgtable.h>
 
+#ifndef kasan_arch_is_ready
+static inline bool kasan_arch_is_ready(void)	{ return true; }
+#endif
+
 extern unsigned char kasan_early_shadow_page[PAGE_SIZE];
 extern pte_t kasan_early_shadow_pte[PTRS_PER_PTE];
 extern pmd_t kasan_early_shadow_pmd[PTRS_PER_PMD];
diff --git a/mm/kasan/generic.c b/mm/kasan/generic.c
index ccb6207276e3..696c2f5b902b 100644
--- a/mm/kasan/generic.c
+++ b/mm/kasan/generic.c
@@ -170,6 +170,9 @@ static __always_inline void check_memory_region_inline(unsigned long addr,
 						size_t size, bool write,
 						unsigned long ret_ip)
 {
+	if (!kasan_arch_is_ready())
+		return;
+
 	if (unlikely(size == 0))
 		return;
 
-- 
2.13.3

