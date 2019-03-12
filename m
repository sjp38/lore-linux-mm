Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 387E0C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDBAE213A2
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="Dh61WMl2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDBAE213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C4098E000A; Tue, 12 Mar 2019 18:16:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 727038E0008; Tue, 12 Mar 2019 18:16:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 576FC8E000A; Tue, 12 Mar 2019 18:16:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id E76DC8E0008
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:16:15 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id z16so1619379wrt.0
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:16:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=FcoH0MWZdtOBuC7W/yk0A9+bmiNTMQTCcIimrSkyq24=;
        b=Lm78LUVBFW48RmlqAJNTGtjtmNah05iTYvR13xH0vR7QIcUTsYcSyAkreuf05VGoGo
         EDvvJqZ77pj6cRTahKsht61eMGClFu1UvAy4CbMQoQEwapgbcaaGWaQmQ14UzFgzOnWR
         yvlC3BlLxH2bmALZkc5CMnymxqHyHPGflnT0Pko8rYrxJvzChV9zyCHl2yL0b/FYDjQ9
         AwtEj9qUq9H/3ghsB+oz5f1NB6UXIdYuy1sttr3Rjiq9H9FUw5LARAxmvzW5A4QxFc7e
         cE8JPd/1oVrijC/QahIoqCxqqfn5eLSEAV2Y4p4hgGstDu8DDYu+s6VK6ELc/SQjzych
         J+Lg==
X-Gm-Message-State: APjAAAV/8hcwGRHzlae3bxLyWG+syZSwWsAk6YkZCPl5CQ/CV5fy8Lw3
	+uYkFgNehJrsNceSNxr3kXBoJcecgqsOjy94EqeJVit4sMD+QhXaq9I+aUMpLwah9wVyVugECbb
	TrhmxJA9uu8lIY8+NSt3LoEbkDlgNT+a1S4u+gxvZjkgHajzfJBHiFmkCI5dG6CBFKA==
X-Received: by 2002:a1c:2ec4:: with SMTP id u187mr21036wmu.29.1552428975212;
        Tue, 12 Mar 2019 15:16:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJUuGEgCd3OwWkPR9tjboT6/bCie+1nI26aMTrNZMQAgl30PhYvMc8cslMxjk0bUYvMN9B
X-Received: by 2002:a1c:2ec4:: with SMTP id u187mr21008wmu.29.1552428973966;
        Tue, 12 Mar 2019 15:16:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552428973; cv=none;
        d=google.com; s=arc-20160816;
        b=OVxatd40q8aGQ+Qz8cVZKALMO/kfPLU/Q13c2SmudrBWIQDoTNWclrmNTAEGn9+eQW
         CXDvY0CgGrNzOCWuAhtYl+TtQqQtrRG0ZceCKpEAbtJ8AMfuf4PnbolDlXIszdq7nUHJ
         17ja6i+wyR8uYuY+2Ibq93J/7bXnxIFGWionk2dd09DV8zOA7O5Ks/YbcRzVsIYRrpVx
         CrOsovAWDKuhwNnoN5BVGTmayKeakv2eQOKPOVYRN0SutDKuuFPBLUd/K186zY9AgTxq
         YSOp4EyRChR0qD7SBVkxQjAVhw5fKoUEsVMj1DU44kXAKUsglFLeQQ6ZIatNtijc5mpU
         Vdpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=FcoH0MWZdtOBuC7W/yk0A9+bmiNTMQTCcIimrSkyq24=;
        b=NzsbGrX1FD3fHR84nWyQZiGQ7D+NnN2eTx57pd2W3VrcuQAgpWY5sjBsmPmtnT3Llf
         ar6xygmTXoYSsAXg+CJeDloAevLMWQe8XyEG0gZWZr6zNh1eyXrKD5ZOkov5N5mHjQWo
         JGviXLi29bXsaj5xhnZyfy6lIbM79ir47buO3QK2oeh6qvn4Goa3u0XfYtsCU4FEaSbP
         x09xyLKSakEQWC0ofALBC2s00haqphYI6YoJsrGLbvrKUn0HD2BeYrauL1nlsxo/76S4
         DpZCy+2+ZF+S0QcLhn2jTkQ6Xp7NHcmrlujdAufsFLICK/ABVK4LrIDpxacJ+0kKiVsD
         is5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=Dh61WMl2;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id p4si1195747wrm.281.2019.03.12.15.16.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 15:16:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=Dh61WMl2;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44Jq7K1HxzzB09Zq;
	Tue, 12 Mar 2019 23:16:13 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=Dh61WMl2; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id UY3xorVjAvzJ; Tue, 12 Mar 2019 23:16:13 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44Jq7K07TzzB09ZG;
	Tue, 12 Mar 2019 23:16:13 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1552428973; bh=FcoH0MWZdtOBuC7W/yk0A9+bmiNTMQTCcIimrSkyq24=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=Dh61WMl2c67y4cwzG934jpk3Yi5ydkkHhikzBl19vVw9LvJW150+Qrw97nzbVCUyY
	 LF7L/zcaBD/9YMdOwyriO/GYYmJOJqerdqn/ZuIIeU/ZeLOhoUQ2z+6vAQ9Hz+7WEC
	 TbZkOU42NMRm5fnmzgt+d3m57eKQmPgo0ndWnKIM=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 38FF48B8B1;
	Tue, 12 Mar 2019 23:16:13 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id 9lw61lSVAl-n; Tue, 12 Mar 2019 23:16:13 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 0C92B8B8A7;
	Tue, 12 Mar 2019 23:16:13 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id D178E6FA15; Tue, 12 Mar 2019 22:16:12 +0000 (UTC)
Message-Id: <96efc03aff3ce13f22cb7da0adb6267b9dbaa2c3.1552428161.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1552428161.git.christophe.leroy@c-s.fr>
References: <cover.1552428161.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v10 07/18] powerpc/32: use memset() instead of memset_io() to
 zero BSS
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 12 Mar 2019 22:16:12 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since commit 400c47d81ca38 ("powerpc32: memset: only use dcbz once cache is
enabled"), memset() can be used before activation of the cache,
so no need to use memset_io() for zeroing the BSS.

Acked-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/early_32.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/kernel/early_32.c b/arch/powerpc/kernel/early_32.c
index cf3cdd81dc47..3482118ffe76 100644
--- a/arch/powerpc/kernel/early_32.c
+++ b/arch/powerpc/kernel/early_32.c
@@ -21,8 +21,8 @@ notrace unsigned long __init early_init(unsigned long dt_ptr)
 {
 	unsigned long offset = reloc_offset();
 
-	/* First zero the BSS -- use memset_io, some platforms don't have caches on yet */
-	memset_io((void __iomem *)PTRRELOC(&__bss_start), 0, __bss_stop - __bss_start);
+	/* First zero the BSS */
+	memset(PTRRELOC(&__bss_start), 0, __bss_stop - __bss_start);
 
 	/*
 	 * Identify the CPU type and fix up code sections
-- 
2.13.3

