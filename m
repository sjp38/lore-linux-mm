Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8C3FC3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 19:13:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9583E2070B
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 19:13:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=embeddedor.com header.i=@embeddedor.com header.b="n8RtI46E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9583E2070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=embeddedor.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 35FE66B000D; Thu, 29 Aug 2019 15:13:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 310B46B000E; Thu, 29 Aug 2019 15:13:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1FF4A6B0010; Thu, 29 Aug 2019 15:13:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0219.hostedemail.com [216.40.44.219])
	by kanga.kvack.org (Postfix) with ESMTP id F42186B000D
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 15:13:15 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id A14861F36B
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 19:13:15 +0000 (UTC)
X-FDA: 75876413550.17.burn97_90d27cc357858
X-HE-Tag: burn97_90d27cc357858
X-Filterd-Recvd-Size: 3710
Received: from gateway22.websitewelcome.com (gateway22.websitewelcome.com [192.185.46.229])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 19:13:15 +0000 (UTC)
Received: from cm13.websitewelcome.com (cm13.websitewelcome.com [100.42.49.6])
	by gateway22.websitewelcome.com (Postfix) with ESMTP id 76CC8E46A
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 14:13:14 -0500 (CDT)
Received: from gator4166.hostgator.com ([108.167.133.22])
	by cmsmtp with SMTP
	id 3Pr8iPv0r3Qi03Pr8i5135; Thu, 29 Aug 2019 14:13:14 -0500
X-Authority-Reason: nr=8
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=embeddedor.com; s=default; h=Content-Type:MIME-Version:Message-ID:Subject:
	Cc:To:From:Date:Sender:Reply-To:Content-Transfer-Encoding:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:
	List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=LZLOm2++l1naemUsyzQnXFmXAnTsZQhTqpdUzFnNKxY=; b=n8RtI46EYyP6e+aDhBNoWMs7nk
	Q+sWYV8NGP79X12UG3yhnImVmD0HmY1asw6EteejVBZmtp7cmpjVbAVh1wif5UbNtnmJ7ohrNOuBR
	eF4m5iQf/ikkAE9UkI0ESE/U99WCQfUbbsFKKvUG29KppSjMyApmMjmAU8J5yOyWwJ80zXDqcu9PD
	7r/0XPaK5SPCzDLJrZs+mPcrCHfVtJLU72qdWu5WtSubne3TDuFNX5N4HLsgo1ebujytab7mjMz6q
	AaUcBCVU8Eijl3ejKYSL4dLYDEFWFo5BsxlYGX1vg/DyHs81YhtirfQOycW0bDma/GZk+Q+WhQYSX
	sJ2H6Z0Q==;
Received: from [189.152.216.116] (port=45196 helo=embeddedor)
	by gator4166.hostgator.com with esmtpa (Exim 4.92)
	(envelope-from <gustavo@embeddedor.com>)
	id 1i3Pr7-001vxh-AQ; Thu, 29 Aug 2019 14:13:13 -0500
Date: Thu, 29 Aug 2019 14:13:12 -0500
From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	"Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: [PATCH] mm/z3fold.c: remove useless code in z3fold_page_isolate
Message-ID: <20190829191312.GA20298@embeddedor>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.9.4 (2018-02-28)
X-AntiAbuse: This header was added to track abuse, please include it with any abuse report
X-AntiAbuse: Primary Hostname - gator4166.hostgator.com
X-AntiAbuse: Original Domain - kvack.org
X-AntiAbuse: Originator/Caller UID/GID - [47 12] / [47 12]
X-AntiAbuse: Sender Address Domain - embeddedor.com
X-BWhitelist: no
X-Source-IP: 189.152.216.116
X-Source-L: No
X-Exim-ID: 1i3Pr7-001vxh-AQ
X-Source: 
X-Source-Args: 
X-Source-Dir: 
X-Source-Sender: (embeddedor) [189.152.216.116]:45196
X-Source-Auth: gustavo@embeddedor.com
X-Email-Count: 7
X-Source-Cap: Z3V6aWRpbmU7Z3V6aWRpbmU7Z2F0b3I0MTY2Lmhvc3RnYXRvci5jb20=
X-Local-Domain: yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Remove duplicate and useless code.

Reported-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
---
 mm/z3fold.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 75b7962439ff..044b7075d0ba 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -1400,15 +1400,13 @@ static bool z3fold_page_isolate(struct page *page, isolate_mode_t mode)
 			 * can call the release logic.
 			 */
 			if (unlikely(kref_put(&zhdr->refcount,
-					      release_z3fold_page_locked))) {
+					      release_z3fold_page_locked)))
 				/*
 				 * If we get here we have kref problems, so we
 				 * should freak out.
 				 */
 				WARN(1, "Z3fold is experiencing kref problems\n");
-				z3fold_page_unlock(zhdr);
-				return false;
-			}
+
 			z3fold_page_unlock(zhdr);
 			return false;
 		}
-- 
2.23.0


