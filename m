Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B02AC3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 01:45:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2ECAB2184E
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 01:45:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lk9B74sU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2ECAB2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEF866B0006; Sun, 18 Aug 2019 21:45:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9FB66B0007; Sun, 18 Aug 2019 21:45:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B51F6B000C; Sun, 18 Aug 2019 21:45:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0218.hostedemail.com [216.40.44.218])
	by kanga.kvack.org (Postfix) with ESMTP id 79C676B0006
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 21:45:35 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 1C5AD37E7
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 01:45:35 +0000 (UTC)
X-FDA: 75837485430.09.snow98_139d7047f9c0f
X-HE-Tag: snow98_139d7047f9c0f
X-Filterd-Recvd-Size: 3950
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com [209.85.215.193])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 01:45:34 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id k3so183576pgb.10
        for <linux-mm@kvack.org>; Sun, 18 Aug 2019 18:45:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references;
        bh=8ulvqLtIjt1EZTpvZlOcKq5+wnFD1h6zkmMfE2XMDMs=;
        b=lk9B74sUPKdnznjzJvazsFGf5amGxQcibjlqaGnEJyrgRa1yrVBIYoiiLv6/n15Gzr
         CfiTp8gC5/lBWIpK+kliQKnmLLV05RdtIzRtRTzeyMW446M0t5liiraWlz7Rg0CpmYBA
         osyAaWTkhvczzTT2Huyrl9smQVOaIamZY+mv5xYJOQCGWJCc1Vbaskf2qj1xT0QChH1J
         lR/0o2YrH2Oc+cMqjfiF6Qo4fbVs0cIyaklprx5n/LhIIrxIGK1W1M52HdSxgHovkNdx
         asYaF96OU2XCimqFH/b2CLkppQkyqPfhu8Ggr1EHPCg/lNKexpER+Hl4Xjg2iMDQw5v3
         Qzcw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references;
        bh=8ulvqLtIjt1EZTpvZlOcKq5+wnFD1h6zkmMfE2XMDMs=;
        b=dT9n7cS4/4aRiVSrXQCtLdO9GCr85Tbq5v1AsRywJpWM2gx36fzeNb4/OAp2D+K9FF
         wm9+zu7ujQrgkGoQkOED7WhuE4bckmPPyaUhGzEBPN4MfLuthsUnN6eTTMayP18Q0X1T
         qkPeVje+zktsKwyhCzHiJEqHEWljgYF5Ec7mqB203x6XjiBWyCP6hb8JLnex54j35Mzo
         oOVMl7nFVksNkrU1uuDYjKwcMj70MMN4NmGEtl2Z+N6oeTP7MAgZZEqjfFSIxVDlfAj/
         hqdiAyUV0K4kEeohRYc3moNk4CeDtFryhYvfUbYciTyIOnCN0JqpNxQAPbhJuX8V/T8Z
         5kyQ==
X-Gm-Message-State: APjAAAVN9CXvbSKwP/+1ygkciTp6IKqglvJS/X5yaxSMsiyjk16VgvBH
	0AEGpDyf4ZonRvHxDni/5fA=
X-Google-Smtp-Source: APXvYqxbfn6JAf2SZn6812vnEPToa4GjGn1SpXMPO49PKbkgenbO9egoQ9AbZaJDQPHs62M3EtUiBQ==
X-Received: by 2002:aa7:9298:: with SMTP id j24mr21172221pfa.58.1566179133706;
        Sun, 18 Aug 2019 18:45:33 -0700 (PDT)
Received: from bj03382pcu.spreadtrum.com ([117.18.48.82])
        by smtp.gmail.com with ESMTPSA id k5sm16293114pfg.167.2019.08.18.18.45.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 18 Aug 2019 18:45:33 -0700 (PDT)
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	Zhaoyang Huang <zhaoyang.huang@unisoc.com>,
	Russell King <linux@armlinux.org.uk>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Rob Herring <robh@kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Doug Berger <opendmb@gmail.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2] arch : arm : add a criteria for pfn_valid
Date: Mon, 19 Aug 2019 09:45:20 +0800
Message-Id: <1566179120-5910-1-git-send-email-huangzhaoyang@gmail.com>
X-Mailer: git-send-email 1.7.9.5
In-Reply-To: <1566178569-5674-1-git-send-email-huangzhaoyang@gmail.com>
References: <1566178569-5674-1-git-send-email-huangzhaoyang@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>

pfn_valid can be wrong when parsing a invalid pfn whose phys address
exceeds BITS_PER_LONG as the MSB will be trimed when shifted.

Signed-off-by: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
---
v2: use __pfn_to_phys/__phys_to_pfn instead of max_pfn as the criteria
---
 arch/arm/mm/init.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index c2daabb..cc769fa 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -177,6 +177,11 @@ static void __init zone_sizes_init(unsigned long min, unsigned long max_low,
 #ifdef CONFIG_HAVE_ARCH_PFN_VALID
 int pfn_valid(unsigned long pfn)
 {
+	phys_addr_t addr = __pfn_to_phys(pfn);
+
+	if (__phys_to_pfn(addr) != pfn)
+		return 0;
+
 	return memblock_is_map_memory(__pfn_to_phys(pfn));
 }
 EXPORT_SYMBOL(pfn_valid);
-- 
1.9.1


