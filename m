Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76C0AC3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 01:36:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A22F206DF
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 01:36:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rmwhJ68b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A22F206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE0FE6B0006; Sun, 18 Aug 2019 21:36:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B91EC6B0007; Sun, 18 Aug 2019 21:36:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A59606B000C; Sun, 18 Aug 2019 21:36:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0118.hostedemail.com [216.40.44.118])
	by kanga.kvack.org (Postfix) with ESMTP id 8462F6B0006
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 21:36:23 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 31D6D8248AAB
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 01:36:23 +0000 (UTC)
X-FDA: 75837462246.01.gold71_54d04cca0b62c
X-HE-Tag: gold71_54d04cca0b62c
X-Filterd-Recvd-Size: 3672
Received: from mail-pl1-f193.google.com (mail-pl1-f193.google.com [209.85.214.193])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 01:36:22 +0000 (UTC)
Received: by mail-pl1-f193.google.com with SMTP id 4so140617pld.10
        for <linux-mm@kvack.org>; Sun, 18 Aug 2019 18:36:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id;
        bh=LSOAA5WYzKw0JvVlfOw/ASbOuyrAtA84sOX9wyeMQQk=;
        b=rmwhJ68bsyBgvRaAN2KzT5g9kG+b9OwIFCFDoEZNKXTlaXBq8OespKeAsa2UGSXMPX
         7us1NQh2WtencQSZrs4QcBmftwAO3G6968wZpjQH/Ul4KSa6+S2En5SDEtStyk8J0KoC
         9vtWESAKBB4cNHBCZT2ChDq/vuSrv18J+Ssp4EhZ5IYIzJrIYbfYxLSdX8d8Wy4s9nmh
         fOXGLIRf6jpRo3TNeBn47J9Y/TVC98rzBXOLBq5+j30tqOzVmPMrh64lraCfcKnJWq+j
         7qVu+DiRlu3TdXPJUxvhyDLnrOlb66whXG/si0XnFKwACEdNUeiRryLQV6FDllsM3n4Q
         XGeg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id;
        bh=LSOAA5WYzKw0JvVlfOw/ASbOuyrAtA84sOX9wyeMQQk=;
        b=MqE2+CUx83ykyy+jkpOtka3nS+nzCP2pf/4j4WjHFVONrvOwo5ZelT2MgjyRVSxU1N
         4Gtjhj3s2cK2096cyJB9RgpF5NEhhOERZUJUJMyJ8eimJn2afpJCQFG2rqmMHdHv+E76
         SQNy9jP/X2i8drf5dqKzbZJvsdgHi51J+wOcFGCBPIAeyKrr6MPGsTnctF1VvO+OAWjq
         PArsT2MHfaZHPbJv7vy9P7/Ra4t8jRHD67vKR7vpVvEBtIPttLP7oznvrFtuh7fm6Zta
         qSSd75vZTXeqJL1rEaB4L0qRYLAP5W7E/HcifRcxDNz9PYWlgN50WH30laF1usUNeSD0
         LKoQ==
X-Gm-Message-State: APjAAAWjuINWYokIv72WpdcEvoCcF4KN87qi5aUDZ79/0hzEIQO2P+ZM
	utfjLX83OzWEFEiuG656TBw=
X-Google-Smtp-Source: APXvYqxG/5xLYdDoMuufP03PO6w1afA06ovqP1QxFMYGOHzw7r7TeRUsj7e1a+629jm6Au0LWtVnYA==
X-Received: by 2002:a17:902:4383:: with SMTP id j3mr19718912pld.69.1566178581777;
        Sun, 18 Aug 2019 18:36:21 -0700 (PDT)
Received: from bj03382pcu.spreadtrum.com ([117.18.48.82])
        by smtp.gmail.com with ESMTPSA id 16sm24011616pfc.66.2019.08.18.18.36.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 18 Aug 2019 18:36:21 -0700 (PDT)
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
Date: Mon, 19 Aug 2019 09:36:09 +0800
Message-Id: <1566178569-5674-1-git-send-email-huangzhaoyang@gmail.com>
X-Mailer: git-send-email 1.7.9.5
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


