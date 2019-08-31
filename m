Return-Path: <SRS0=LT00=W3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CD1DC3A59B
	for <linux-mm@archiver.kernel.org>; Sat, 31 Aug 2019 01:15:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13A50217D7
	for <linux-mm@archiver.kernel.org>; Sat, 31 Aug 2019 01:15:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13A50217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6541D6B0006; Fri, 30 Aug 2019 21:15:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 605676B0008; Fri, 30 Aug 2019 21:15:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51B5B6B000A; Fri, 30 Aug 2019 21:15:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0217.hostedemail.com [216.40.44.217])
	by kanga.kvack.org (Postfix) with ESMTP id 30D5F6B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 21:15:13 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id B1151A2A2
	for <linux-mm@kvack.org>; Sat, 31 Aug 2019 01:15:12 +0000 (UTC)
X-FDA: 75880954464.01.cast84_104a2e7168541
X-HE-Tag: cast84_104a2e7168541
X-Filterd-Recvd-Size: 1893
Received: from huawei.com (szxga05-in.huawei.com [45.249.212.191])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 31 Aug 2019 01:15:11 +0000 (UTC)
Received: from DGGEMS408-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id E9AD5E7DEF6F51EA2CED;
	Sat, 31 Aug 2019 09:15:08 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS408-HUB.china.huawei.com (10.3.19.208) with Microsoft SMTP Server id
 14.3.439.0; Sat, 31 Aug 2019 09:14:59 +0800
From: Kefeng Wang <wangkefeng.wang@huawei.com>
To: <linux-mm@kvack.org>
CC: Andrew Morton <akpm@linux-foundation.org>, Kefeng Wang
	<wangkefeng.wang@huawei.com>
Subject: [PATCH] mm: do not hash address in print_bad_pte()
Date: Sat, 31 Aug 2019 09:18:16 +0800
Message-ID: <20190831011816.141002-1-wangkefeng.wang@huawei.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.175.113.25]
X-CFilter-Loop: Reflected
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Using %px to show the actual address in print_bad_pte()
to help us to debug issue.

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---
 mm/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index e2bb51b6242e..3f0874c9ca38 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -518,7 +518,7 @@ static void print_bad_pte(struct vm_area_struct *vma,=
 unsigned long addr,
 		 (long long)pte_val(pte), (long long)pmd_val(*pmd));
 	if (page)
 		dump_page(page, "bad pte");
-	pr_alert("addr:%p vm_flags:%08lx anon_vma:%p mapping:%p index:%lx\n",
+	pr_alert("addr:%px vm_flags:%08lx anon_vma:%px mapping:%px index:%lx\n"=
,
 		 (void *)addr, vma->vm_flags, vma->anon_vma, mapping, index);
 	pr_alert("file:%pD fault:%ps mmap:%ps readpage:%ps\n",
 		 vma->vm_file,
--=20
2.20.1


