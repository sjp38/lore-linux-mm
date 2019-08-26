Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC017C3A5A4
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 03:06:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F64C206E0
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 03:06:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=embeddedor.com header.i=@embeddedor.com header.b="k+L8HgGt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F64C206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=embeddedor.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2AEF06B051C; Sun, 25 Aug 2019 23:06:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 239AE6B051D; Sun, 25 Aug 2019 23:06:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D8D96B051E; Sun, 25 Aug 2019 23:06:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0147.hostedemail.com [216.40.44.147])
	by kanga.kvack.org (Postfix) with ESMTP id DB3516B051C
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 23:06:39 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 80AD8482C
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 03:06:39 +0000 (UTC)
X-FDA: 75863091318.19.toe45_744584b47be12
X-HE-Tag: toe45_744584b47be12
X-Filterd-Recvd-Size: 3564
Received: from gateway24.websitewelcome.com (gateway24.websitewelcome.com [192.185.51.56])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 03:06:38 +0000 (UTC)
Received: from cm13.websitewelcome.com (cm13.websitewelcome.com [100.42.49.6])
	by gateway24.websitewelcome.com (Postfix) with ESMTP id 03155C73A
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 22:06:38 -0500 (CDT)
Received: from gator4166.hostgator.com ([108.167.133.22])
	by cmsmtp with SMTP
	id 25L3iSJZz3Qi025L3i84cc; Sun, 25 Aug 2019 22:06:38 -0500
X-Authority-Reason: nr=8
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=embeddedor.com; s=default; h=Content-Type:MIME-Version:Message-ID:Subject:
	Cc:To:From:Date:Sender:Reply-To:Content-Transfer-Encoding:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:
	List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=Nhx5OiP7r0dYpbGQdFUd0gr/5YT1Ihavje6uRy4hWMQ=; b=k+L8HgGtHnF9vb85fjf0bIhaJn
	4kLqVLiQtaUzgqgNobmb1ASxxWaChh7tMtQw/FPmX3uCLbhJmdn+huWyqQkRx9Yqd12R89xTe0kSW
	Dy1Y9bxs4JWgQ3L3B865+CqSPt8sFZ8OaHtH5tIB+w3Jh618d5sPoM8CPB+4XSis/CURwp+BrVLBA
	1sw2OEjFpOK8UWnJoNYxx5KxxENle5dDrH8oT9NjrpVQEbxigar/jEMF+uZudqwQeHmsvEI7sGZvO
	i4Kxrlm1jSN5+1bcp1GzKsggsdhMIHn6eU2vrEurQd55dIbwlqk6DC5bPrfLw1Q8xB3EG6Z1JSXnO
	bwGmxJAA==;
Received: from [189.152.216.116] (port=45992 helo=embeddedor)
	by gator4166.hostgator.com with esmtpa (Exim 4.92)
	(envelope-from <gustavo@embeddedor.com>)
	id 1i25L2-003wZG-0L; Sun, 25 Aug 2019 22:06:36 -0500
Date: Sun, 25 Aug 2019 22:06:34 -0500
From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	Henry Burns <henryburns@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	"Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: [PATCH] mm/z3fold.c: fix lock/unlock imbalance in z3fold_page_isolate
Message-ID: <20190826030634.GA4379@embeddedor>
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
X-Exim-ID: 1i25L2-003wZG-0L
X-Source: 
X-Source-Args: 
X-Source-Dir: 
X-Source-Sender: (embeddedor) [189.152.216.116]:45992
X-Source-Auth: gustavo@embeddedor.com
X-Email-Count: 3
X-Source-Cap: Z3V6aWRpbmU7Z3V6aWRpbmU7Z2F0b3I0MTY2Lmhvc3RnYXRvci5jb20=
X-Local-Domain: yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Fix lock/unlock imbalance by unlocking *zhdr* before return.

Addresses-Coverity-ID: 1452811 ("Missing unlock")
Fixes: d776aaa9895e ("mm/z3fold.c: fix race between migration and destruction")
Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
---
 mm/z3fold.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index e31cd9bd4ed5..75b7962439ff 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -1406,6 +1406,7 @@ static bool z3fold_page_isolate(struct page *page, isolate_mode_t mode)
 				 * should freak out.
 				 */
 				WARN(1, "Z3fold is experiencing kref problems\n");
+				z3fold_page_unlock(zhdr);
 				return false;
 			}
 			z3fold_page_unlock(zhdr);
-- 
2.23.0


