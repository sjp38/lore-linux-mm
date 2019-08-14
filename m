Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BFBCC32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 18:33:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E3C72133F
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 18:33:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="QEFYliYm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E3C72133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3B5B6B0005; Wed, 14 Aug 2019 14:33:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC2E86B0007; Wed, 14 Aug 2019 14:33:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98B276B0008; Wed, 14 Aug 2019 14:33:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0136.hostedemail.com [216.40.44.136])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0BD6B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 14:33:10 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 0EBA5181AC9AE
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 18:33:10 +0000 (UTC)
X-FDA: 75821880540.10.crook91_55cecc2d19807
X-HE-Tag: crook91_55cecc2d19807
X-Filterd-Recvd-Size: 3584
Received: from mail-qt1-f172.google.com (mail-qt1-f172.google.com [209.85.160.172])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 18:33:09 +0000 (UTC)
Received: by mail-qt1-f172.google.com with SMTP id i4so2747677qtj.8
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 11:33:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=a7VsLFWMqOK5QBGftp4DGOIRVxFfDzWSvXbi6s9WXSY=;
        b=QEFYliYmrCuKePZfglkjulUgR6y+rScw4FXOVaQO6wi+jp/Ip4hmRTbR9lmogQKKFO
         AY4NToD66LZNT0QxOwsKFhoxVtBglCZF3VdZPlROqs+MlnSsq+i3ZDOq7TbtzNT9yYzw
         yknOdkrphpep7i7E1MLD15yEiRbNiq5owflBseNX4oBf0RKk0I9hJAufGdBEoqDa22Lo
         qa4vayt60S0tEd2Gji4vY/tdWDsF2HuVxATy4tEOkFzYv7DngjLaQpEZDJbcjN2rVP0p
         hDtheDGN10dnOgqHRJU+DIQGwCawqIDZXRyz6sLvbtFxfljjNHuFOgCvc59lBWK61jdu
         P8Bg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=a7VsLFWMqOK5QBGftp4DGOIRVxFfDzWSvXbi6s9WXSY=;
        b=cY4HkDVKuu3fM5X6fYCn+J/yu4f0M0fQYOQvvm4LbzYeLgi+ydvdMeHxEM3dATRVH1
         YATno38pFprGyJ/Q9c7KzTahZGNH9+XnRUp2cAT0GAEnIlY0//aMr1J6kCPHuFP4lepA
         lOAiszbuFr0nC3dyG5cqYcdRUMAV1s6LIj/iMJcGmW9MAwJobK/ZkKB3+zoa6GHEXoYS
         aGtU9+ubIOE6hrPGqbZh9sbdS1+cSTmK13Jqg2GnuvgAwvOpgA/noFgZ1M5XL7o+0E16
         xGs1Ihhw/styqvncyRpfDG93M+ZuJyURnkOo4D95OcbyBcWublxDT1+djc8KGLoHNeob
         Trmw==
X-Gm-Message-State: APjAAAV+c263/1uApjjPOFtQaTQMnDS8GijM/9fvpP1ojislSnNipGfi
	gmR0lBIa+ibwIdt6k92WirMFXLRH0bA=
X-Google-Smtp-Source: APXvYqwMuwKyYCpL2+otD6j1gk/bschN93ksmfQMvwSAUNE6ackQhWxes3MQ8TV5Ong8ZOe1hAjGVQ==
X-Received: by 2002:a0c:d981:: with SMTP id y1mr867094qvj.104.1565807588862;
        Wed, 14 Aug 2019 11:33:08 -0700 (PDT)
Received: from qcai.nay.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id w1sm226000qte.36.2019.08.14.11.33.07
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Aug 2019 11:33:08 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: catalin.marinas@arm.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH -next] mm/kmemleak: increase the max mem pool to 1M
Date: Wed, 14 Aug 2019 14:32:52 -0400
Message-Id: <1565807572-26041-1-git-send-email-cai@lca.pw>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There are some machines with slow disk and fast CPUs. When they are
under memory pressure, it could take a long time to swap before the OOM
kicks in to free up some memory. As the results, it needs a large
mem pool for kmemleak or suffering from higher chance of a kmemleak
metadata allocation failure. 524288 proves to be the good number for all
architectures here. Increase the upper bound to 1M to leave some room
for the future.

Signed-off-by: Qian Cai <cai@lca.pw>
---
 lib/Kconfig.debug | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index e80a745a11e2..d962c72a8bb5 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -595,7 +595,7 @@ config DEBUG_KMEMLEAK
 config DEBUG_KMEMLEAK_MEM_POOL_SIZE
 	int "Kmemleak memory pool size"
 	depends on DEBUG_KMEMLEAK
-	range 200 40000
+	range 200 1000000
 	default 16000
 	help
 	  Kmemleak must track all the memory allocations to avoid
-- 
1.8.3.1


