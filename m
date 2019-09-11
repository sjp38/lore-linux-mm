Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47AB5C49ED9
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 03:09:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15FED21928
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 03:09:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15FED21928
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=cn.fujitsu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A18206B0007; Tue, 10 Sep 2019 23:09:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C8926B0008; Tue, 10 Sep 2019 23:09:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B6796B000A; Tue, 10 Sep 2019 23:09:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0067.hostedemail.com [216.40.44.67])
	by kanga.kvack.org (Postfix) with ESMTP id 6B3696B0007
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 23:09:13 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 0B6591E06F
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 03:09:13 +0000 (UTC)
X-FDA: 75921158586.21.gold21_3345b1eb11b60
X-HE-Tag: gold21_3345b1eb11b60
X-Filterd-Recvd-Size: 2551
Received: from heian.cn.fujitsu.com (mail.cn.fujitsu.com [183.91.158.132])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 03:09:11 +0000 (UTC)
X-IronPort-AV: E=Sophos;i="5.64,491,1559491200"; 
   d="scan'208";a="75262210"
Received: from unknown (HELO cn.fujitsu.com) ([10.167.33.5])
  by heian.cn.fujitsu.com with ESMTP; 11 Sep 2019 11:09:09 +0800
Received: from G08CNEXCHPEKD01.g08.fujitsu.local (unknown [10.167.33.80])
	by cn.fujitsu.com (Postfix) with ESMTP id 051084CE030A;
	Wed, 11 Sep 2019 11:08:56 +0800 (CST)
Received: from TSAO.g08.fujitsu.local (10.167.226.60) by
 G08CNEXCHPEKD01.g08.fujitsu.local (10.167.33.89) with Microsoft SMTP Server
 (TLS) id 14.3.439.0; Wed, 11 Sep 2019 11:09:11 +0800
From: Cao jin <caoj.fnst@cn.fujitsu.com>
To: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
CC: <rppt@linux.ibm.com>
Subject: [PATCH] mm/memblock: fix typo in memblock doc
Date: Wed, 11 Sep 2019 11:08:56 +0800
Message-ID: <20190911030856.18010-1-caoj.fnst@cn.fujitsu.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.167.226.60]
X-yoursite-MailScanner-ID: 051084CE030A.A9008
X-yoursite-MailScanner: Found to be clean
X-yoursite-MailScanner-From: caoj.fnst@cn.fujitsu.com
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

elaboarte -> elaborate
architecure -> architecture
compltes -> completes

Signed-off-by: Cao jin <caoj.fnst@cn.fujitsu.com>
---
 mm/memblock.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 7d4f61ae666a..0d0f92003d18 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -83,16 +83,16 @@
  * Note, that both API variants use implict assumptions about allowed
  * memory ranges and the fallback methods. Consult the documentation
  * of :c:func:`memblock_alloc_internal` and
- * :c:func:`memblock_alloc_range_nid` functions for more elaboarte
+ * :c:func:`memblock_alloc_range_nid` functions for more elaborate
  * description.
  *
  * As the system boot progresses, the architecture specific
  * :c:func:`mem_init` function frees all the memory to the buddy page
  * allocator.
  *
- * Unless an architecure enables %CONFIG_ARCH_KEEP_MEMBLOCK, the
+ * Unless an architecture enables %CONFIG_ARCH_KEEP_MEMBLOCK, the
  * memblock data structures will be discarded after the system
- * initialization compltes.
+ * initialization completes.
  */
=20
 #ifndef CONFIG_NEED_MULTIPLE_NODES
--=20
2.21.0




