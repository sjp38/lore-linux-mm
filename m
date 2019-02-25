Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C829C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 13:48:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E5B620842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 13:48:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="qYalwARn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E5B620842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 149FD8E0155; Mon, 25 Feb 2019 08:48:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D1D08E011F; Mon, 25 Feb 2019 08:48:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F011A8E0155; Mon, 25 Feb 2019 08:48:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 99C918E011F
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 08:48:43 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id 92so3688317wrb.6
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 05:48:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=QhQmZaAZJZ69E9F/zZFRmLWd5K/IsYQno7oOFU3XPxU=;
        b=Wj9uM9fcXHpQqNMzFWYvJGDkL5BSIoESTr+S80LOdXgrZwt0AHrspHwAGog2iXaGQ7
         VfdcAUQGv1UOT4Zkrr01RCMPXWvPE+M1pz6KhmCgsrmPKraOpc+eGn2AfafiCa3m8x1E
         ZaebE7TzIZHvuwVum06ywNS4Kt31ICXKPLbMsq48ao2OWJPmSdpo/25ejAg6m16D+TQl
         XjNLQlgjDr8qJepg0LpszN8TVpKguXNfBzr6PKGPT104bVy9mkaemt+5M7RmJGQw0IE9
         oOTbOyIne2Rk3fhBHPG917hYLQCIxmQgh3nMRvQbUFm4sbIBW24gEdRXvbcFbrv4WiWN
         0YNQ==
X-Gm-Message-State: AHQUAuZEQx6vOmwCoYeq5R6gW/ufDKZnhGPzowh3d8prWR2oSDU4wJtO
	bS0hWoES4bRbB2Uivlq1xZ/mn/hX3lAqWjyScbCDX9uuwk6Kzf8LDUCIOGnUGpK2mTyta76z5tw
	57wm3IGuKcp/t9+3WmXFk1ssDX3pLQwSHoR4jxVjoee/xFma24czlFDvr9p7ExJgS7g==
X-Received: by 2002:adf:deca:: with SMTP id i10mr11988792wrn.312.1551102523172;
        Mon, 25 Feb 2019 05:48:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYZX5ZTyFFaJGiBLHbkx8YKfIlBDTjOgJFff9m2B4561AN7u/fbmizBkru5/hnjIfMItB07
X-Received: by 2002:adf:deca:: with SMTP id i10mr11988756wrn.312.1551102522266;
        Mon, 25 Feb 2019 05:48:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551102522; cv=none;
        d=google.com; s=arc-20160816;
        b=V++9LXL7KTPs5Gbfmw7QDi5ClaLHtYekLBJHcSSEJbHDEwfICUfkhWLGDTn3EdNIS8
         fNUihok21iCJv29ENDcYiu6FvP3qJ2zxpOHcm8efGsspIntlccmVjW7mj6ino2t05reK
         Shs1NXagQAVPFrYM9lBMv4I89twNr1ghrnI+U+EwiK6YFUAdT0SXkTx8wVa1oOiwliU8
         LK5QpGeB7jB/2VrxEWZCMB1UoTTubtDcGkt4XRAN05X6iSfVrI1uNbwJTQJeR8YXlmzD
         o2P3lVDBC+bxpGr5t99vmukv6sEvpIhWfObZg/IuySvghp8b0ibALrDZGXaZ1ud2dCNG
         hvPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=QhQmZaAZJZ69E9F/zZFRmLWd5K/IsYQno7oOFU3XPxU=;
        b=yky3BJf5cL8r45LxD8zkpSwMOgR/F+J2PNDCGSgV0MsYe5+7dtbkGDYmbhVIke5OJ0
         UQwa+GODAxn6f0POMtRPcBhAbN71wcmna5tLjMFO3iiJ1+AEw39YYNLQEz3QHu7TnUX+
         lfQe+xmQEYhhlnzTSmy4JorXKBTXe+jsHJLg7PU7bxQ+hyV0/Ghj5rIn3nXDgTQv3h67
         ZySt37HuCvT2ujWIkq2rEGKnyU4g5jpb12nXJSowJJ3poWnuOACaCOueEL4fTfUcaqIR
         oAEJuIu8ogVlFJ/fHeKNqeqiv3/khk9N9iIVeX13xdqLUo0Pql9brR2AmNepBHY772F9
         sYmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=qYalwARn;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id g192si5387913wmg.188.2019.02.25.05.48.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 05:48:42 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=qYalwARn;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 447NZX5z8MzB09Zr;
	Mon, 25 Feb 2019 14:48:36 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=qYalwARn; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id IWSys9YX47Os; Mon, 25 Feb 2019 14:48:36 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 447NZX4wZSzB09Zn;
	Mon, 25 Feb 2019 14:48:36 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551102516; bh=QhQmZaAZJZ69E9F/zZFRmLWd5K/IsYQno7oOFU3XPxU=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=qYalwARnPCzjIFXETiEBuZ7czi+D4/fUqFN0gAZ9pC/dj/JZsL/y/Zs/qCeRVqRiW
	 vGE0qR8lbWGxYzKxOIaIu13RKCdJDvRhm5zgHqHGvCLCoIpgfiJ9UufqCdOfxaqAQE
	 ZFH23Tpr8T7aFztA7lSVIl5qSndCde/zNFC8sB/U=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 056888B844;
	Mon, 25 Feb 2019 14:48:41 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id j3jW_ZJQWi3J; Mon, 25 Feb 2019 14:48:40 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.2])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id D3DEA8B81D;
	Mon, 25 Feb 2019 14:48:40 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 6D9D16F20E; Mon, 25 Feb 2019 13:48:41 +0000 (UTC)
Message-Id: <be8f68bbfc608d9edba17d74971e33c24294db39.1551098214.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551098214.git.christophe.leroy@c-s.fr>
References: <cover.1551098214.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v7 06/11] powerpc/32: make KVIRT_TOP dependant on FIXMAP_START
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Mon, 25 Feb 2019 13:48:41 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When we add KASAN shadow area, KVIRT_TOP can't be anymore fixed
at 0xfe000000.

This patch uses FIXADDR_START to define KVIRT_TOP.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/include/asm/book3s/32/pgtable.h | 2 +-
 arch/powerpc/include/asm/nohash/32/pgtable.h | 2 +-
 arch/powerpc/mm/init_32.c                    | 1 +
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/32/pgtable.h b/arch/powerpc/include/asm/book3s/32/pgtable.h
index aa8406b8f7ba..008e6237a1b2 100644
--- a/arch/powerpc/include/asm/book3s/32/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/32/pgtable.h
@@ -142,7 +142,7 @@ static inline bool pte_user(pte_t pte)
 #ifdef CONFIG_HIGHMEM
 #define KVIRT_TOP	PKMAP_BASE
 #else
-#define KVIRT_TOP	(0xfe000000UL)	/* for now, could be FIXMAP_BASE ? */
+#define KVIRT_TOP	FIXADDR_START
 #endif
 
 /*
diff --git a/arch/powerpc/include/asm/nohash/32/pgtable.h b/arch/powerpc/include/asm/nohash/32/pgtable.h
index bed433358260..6c4acd842a3e 100644
--- a/arch/powerpc/include/asm/nohash/32/pgtable.h
+++ b/arch/powerpc/include/asm/nohash/32/pgtable.h
@@ -72,7 +72,7 @@ extern int icache_44x_need_flush;
 #ifdef CONFIG_HIGHMEM
 #define KVIRT_TOP	PKMAP_BASE
 #else
-#define KVIRT_TOP	(0xfe000000UL)	/* for now, could be FIXMAP_BASE ? */
+#define KVIRT_TOP	FIXADDR_START
 #endif
 
 /*
diff --git a/arch/powerpc/mm/init_32.c b/arch/powerpc/mm/init_32.c
index 41a3513cadc9..c077ab1a63ea 100644
--- a/arch/powerpc/mm/init_32.c
+++ b/arch/powerpc/mm/init_32.c
@@ -34,6 +34,7 @@
 #include <linux/slab.h>
 #include <linux/hugetlb.h>
 
+#include <asm/fixmap.h>
 #include <asm/pgalloc.h>
 #include <asm/prom.h>
 #include <asm/io.h>
-- 
2.13.3

