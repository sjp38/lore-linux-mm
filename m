Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40833C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 14:47:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0114A2080C
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 14:47:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="LejEUzoE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0114A2080C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E6BF8E001D; Thu,  1 Aug 2019 10:47:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 897648E0001; Thu,  1 Aug 2019 10:47:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 785918E001D; Thu,  1 Aug 2019 10:47:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 59C9E8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 10:47:40 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id x17so61485165qkf.14
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 07:47:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=230s3ChFPRc4aRDJM4ggG97b31ayoZtf71ejiTiSkjo=;
        b=fDaRWeDSibqWMrcaBpEE8nep/2IkWj25ClX4ePMsS7Us9I8uHLd8oNbCvA1wkDv+j6
         g63miLn73HywsOFyMvTF6jZRmFjl6CczWndukPAH9zv4fHju3WIxe39yOG3ZgCibk+Np
         C6hAOW3L+NX/bxTnFXml0NXq85tyYEgdsqRl8Nlw9r0FdzUxm6PoOP9t57xtp7BlbC81
         Ny2X6WldYXBc/TCjSjsLkivL9+LttUNGqFNBbnLq0H+5O/JLOseQ6D9bmVYwknYnFPdi
         aI3DpIu1QpT01pxw+AaiaVbWLrIFB4y8zgQjfn7I88KDhhUex+75EIOqKRgmoY6p0AXH
         HIhQ==
X-Gm-Message-State: APjAAAXv/b6vVAd39a3LxSlVuBg6knD9F2bBtLnSzz3AeVYeDBaD5gT9
	yidJSmDva881n3ti6fa9joV8DUWS8hvQt2F2oHXtMoVMjfv4Kzns9hKqhwURGshDS/9ruVam+3Y
	Lhd80II7/ecAy1YzZTHgCFgkG+eNPcdPRCzZ1HxH28kxigVv70kt9DuSImxc+4MlxVA==
X-Received: by 2002:ac8:234a:: with SMTP id b10mr92071770qtb.261.1564670860101;
        Thu, 01 Aug 2019 07:47:40 -0700 (PDT)
X-Received: by 2002:ac8:234a:: with SMTP id b10mr92071718qtb.261.1564670859363;
        Thu, 01 Aug 2019 07:47:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564670859; cv=none;
        d=google.com; s=arc-20160816;
        b=jlrlkDw+9LwZ4UYW/IL+Nf3TybAcqBA2AKedSpmreoyEZoqAOFkcsdjYDLYT2V4pzP
         +MlPTSp4pz/v7ai16uz8X7NJHRHUlTjnx7bQohsJWaJrDGrkYIRiG6vVSxdUy1/7ui4W
         v9GDK5yz/thYHK7mruISNaezNDWYrNYIuH+VFS7fde2D6GTdhwqKQNyyQjtgFI1Uh4II
         O2edws/xwWL63rfc3m4z1E/sO23u5dRzxYlrv+k99rxaLpsOMn2RkmijLDEHiwIQgBwS
         ckznhvIgDyz+Y4HsQyK8gIo0Fug3vxmFGL+wyOmRBqVTbXXjHZly2Hj4HyapifsHK85o
         Pypg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=230s3ChFPRc4aRDJM4ggG97b31ayoZtf71ejiTiSkjo=;
        b=i77fImvCUdxY4LG+fs1kFz+M1C0sTHXkEovhyLJSumeGDZvY7bzg/LNJnHwGFAB34C
         vBL0G3XkhhYeThbrCnP1m7rnz4JLDxFmOac+qqQdma3bc1GsnJMNkcAucp9ff2R9NHfg
         zrujzt5ZKtn0OK1nYc4w5OxWh73QG2f7g3W4SxDwkbY9bcs3Px3scDKOzl8P0BVChofG
         bbu4FQakpj6KzmUCSaF5sdoGAPbXoFfkIxo+lVHEb2rKroafJhJ4i21X4M3naf/+pKwm
         cTntdQvPqJNCs2WsVadj4rzDtLhZpqXNenHSkRFnyzIywHG+7KOLerB3KB7t990Y1XVK
         Xknw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=LejEUzoE;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k3sor32597332qkg.16.2019.08.01.07.47.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 07:47:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=LejEUzoE;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=230s3ChFPRc4aRDJM4ggG97b31ayoZtf71ejiTiSkjo=;
        b=LejEUzoEVFEhSDCDH1H8Ri6NTYd+EQ93Bl/JO+hFoztUU8LZE/3ThN3ckZztuH/w1v
         9ZBKE0O7YssDOoH1hgL0JQ0pwQ4Tviu5kZ5YskORAs0iZ0+ltBuEKKnhLwhVfoBLyPfz
         d3Etk+ubEBLubY4IdfrS7mP66VUO9gIN8dQBHoQiV1U2dwuvTnBOWlcfbBMbBry5Emjx
         BZLpm9BLNXjMfjYY2AXpHp2FMBW9IHG9JC/MUR6Ray/aqbZgZs+McxqDbeFLvx96PlRU
         4vTWs2/AXl3PmmsA6wFbYZsVzZ/sHRBXrzLSDZRCzYvlG5U6RnMQCkeKXlij42mY/v7e
         ORuQ==
X-Google-Smtp-Source: APXvYqwHfUt80l0BXUJpBGTFwk3Bd4gQ46/mlKzXrLecWYywA/07oGtfuHM8Qz7nWtC7/qhxbBwNVA==
X-Received: by 2002:ae9:e30d:: with SMTP id v13mr83907407qkf.148.1564670859058;
        Thu, 01 Aug 2019 07:47:39 -0700 (PDT)
Received: from qcai.nay.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id s11sm29605818qkm.51.2019.08.01.07.47.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 07:47:38 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: catalin.marinas@arm.com,
	will@kernel.org
Cc: andreyknvl@google.com,
	aryabinin@virtuozzo.com,
	glider@google.com,
	dvyukov@google.com,
	linux-arm-kernel@lists.infradead.org,
	kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH v2] arm64/mm: fix variable 'tag' set but not used
Date: Thu,  1 Aug 2019 10:47:05 -0400
Message-Id: <1564670825-4050-1-git-send-email-cai@lca.pw>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When CONFIG_KASAN_SW_TAGS=n, set_tag() is compiled away. GCC throws a
warning,

mm/kasan/common.c: In function '__kasan_kmalloc':
mm/kasan/common.c:464:5: warning: variable 'tag' set but not used
[-Wunused-but-set-variable]
  u8 tag = 0xff;
     ^~~

Fix it by making __tag_set() a static inline function the same as
arch_kasan_set_tag() in mm/kasan/kasan.h for consistency because there
is a macro in arch/arm64/include/asm/kasan.h,

 #define arch_kasan_set_tag(addr, tag) __tag_set(addr, tag)

However, when CONFIG_DEBUG_VIRTUAL=n and CONFIG_SPARSEMEM_VMEMMAP=y,
page_to_virt() will call __tag_set() with incorrect type of a
parameter, so fix that as well. Also, still let page_to_virt() return
"void *" instead of "const void *", so will not need to add a similar
cast in lowmem_page_address().

Signed-off-by: Qian Cai <cai@lca.pw>
---

v2: Fix compilation warnings of CONFIG_DEBUG_VIRTUAL=n spotted by Will.

 arch/arm64/include/asm/memory.h | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
index b7ba75809751..fb04f10a78ab 100644
--- a/arch/arm64/include/asm/memory.h
+++ b/arch/arm64/include/asm/memory.h
@@ -210,7 +210,11 @@ static inline unsigned long kaslr_offset(void)
 #define __tag_reset(addr)	untagged_addr(addr)
 #define __tag_get(addr)		(__u8)((u64)(addr) >> 56)
 #else
-#define __tag_set(addr, tag)	(addr)
+static inline const void *__tag_set(const void *addr, u8 tag)
+{
+	return addr;
+}
+
 #define __tag_reset(addr)	(addr)
 #define __tag_get(addr)		0
 #endif
@@ -301,8 +305,8 @@ static inline void *phys_to_virt(phys_addr_t x)
 #define page_to_virt(page)	({					\
 	unsigned long __addr =						\
 		((__page_to_voff(page)) | PAGE_OFFSET);			\
-	unsigned long __addr_tag =					\
-		 __tag_set(__addr, page_kasan_tag(page));		\
+	const void *__addr_tag =					\
+		__tag_set((void *)__addr, page_kasan_tag(page));	\
 	((void *)__addr_tag);						\
 })
 
-- 
1.8.3.1

