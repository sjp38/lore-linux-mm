Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42DFBC3A59F
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 03:00:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05BED21721
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 03:00:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="I6fxR2O8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05BED21721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DE286B0007; Fri, 16 Aug 2019 23:00:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 767436B000A; Fri, 16 Aug 2019 23:00:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 62F496B000C; Fri, 16 Aug 2019 23:00:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0119.hostedemail.com [216.40.44.119])
	by kanga.kvack.org (Postfix) with ESMTP id 3AE276B0007
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 23:00:22 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id E26D68248AD9
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 03:00:21 +0000 (UTC)
X-FDA: 75830416242.26.arch07_778ed59e2a719
X-HE-Tag: arch07_778ed59e2a719
X-Filterd-Recvd-Size: 3647
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 03:00:21 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id w2so4072223pfi.3
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 20:00:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id;
        bh=ZNmqO+5oQExi9j6sURYtncJ3cIGe7QR8qkct94PKzGM=;
        b=I6fxR2O84IX+kAUdE0YjnjTo2SkzcFS7bu/CNXFrVBKS7Y0zkNc+GrGJ0B+SAb+fxX
         F184Vt0MgipU/QCEs6xmJfDtN4ptYVLz8S8qhvPxt/wEmjRIguFGV1gEFlZqITQfkBfx
         jq0jsnAz9/j4IJGZUs6aTsCQmFsjc4ADtF4pX41rr3GJ/k7ZunXmybseIDiozPH9QOSB
         khof9WZds2JrVOx7joe6OrNIJh1VjQXu6cpNfWuEYBHuxHuBbpwuv6VihhfyTPHRk5BZ
         FIDJlO/wUSGbISA6qoFf31Gy8XpyUYsrg+KzetFNXh9NJJUqd0Z2AO8aOdgRkQMrRzH9
         1Q0w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id;
        bh=ZNmqO+5oQExi9j6sURYtncJ3cIGe7QR8qkct94PKzGM=;
        b=U/k+aRVDnA1kJ73bDW3Ke7TTyjN3/VjqQAOfA3uUroRFiI74YZ6XGltKQKqHM6bbYY
         4LUFBcOkxfmEN959sN8T1QwhTigBA9L2w8pv6D61QynvBK0Sqim/UrHsaRhFX15biY4D
         wsd6SjkPZXN1HRHgWNizdAFMGyx+Hma+aqR47wlu5jzyuV9s4FuEPV0YUMItrDr+CM6m
         MBKWxNdepXHyvROivOkDtKFHN+spMEJUThZf439E4QfEtHJLgUbdaOlZmADAitNo0l9a
         lO0FZEV83JxBXmHBwthfEphWoZLULTlKVMO9fyviZ/jLhftSWdeNehmKor32UJJwkv3g
         Qmdw==
X-Gm-Message-State: APjAAAXIabNLYT71m9gLGwWhM7sLysyTM17wDeVwVBXyUjUiB0jM2EE7
	Afiwx1djXWLIXZGeGFT5C2k=
X-Google-Smtp-Source: APXvYqw9mXgAJbJGWPUv7KLnt54TBolvSb735/2o2qTm6FCNXPGL4MBESs1wcsP82axZw/+PE4Q0kQ==
X-Received: by 2002:a17:90a:f484:: with SMTP id bx4mr10109470pjb.61.1566010820431;
        Fri, 16 Aug 2019 20:00:20 -0700 (PDT)
Received: from bj03382pcu.spreadtrum.com ([117.18.48.82])
        by smtp.gmail.com with ESMTPSA id n128sm7241440pfn.46.2019.08.16.20.00.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 16 Aug 2019 20:00:19 -0700 (PDT)
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
Subject: [PATCH] arch : arm : add a criteria for pfn_valid
Date: Sat, 17 Aug 2019 11:00:13 +0800
Message-Id: <1566010813-27219-1-git-send-email-huangzhaoyang@gmail.com>
X-Mailer: git-send-email 1.7.9.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>

pfn_valid can be wrong while the MSB of physical address be trimed as pfn
larger than the max_pfn.

Signed-off-by: Zhaoyang Huang <huangzhaoyang@gmail.com>
---
 arch/arm/mm/init.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index c2daabb..9c4d938 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -177,7 +177,8 @@ static void __init zone_sizes_init(unsigned long min, unsigned long max_low,
 #ifdef CONFIG_HAVE_ARCH_PFN_VALID
 int pfn_valid(unsigned long pfn)
 {
-	return memblock_is_map_memory(__pfn_to_phys(pfn));
+	return (pfn > max_pfn) ?
+		false : memblock_is_map_memory(__pfn_to_phys(pfn));
 }
 EXPORT_SYMBOL(pfn_valid);
 #endif
-- 
1.9.1


