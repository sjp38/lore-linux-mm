Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8ED0C43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 14:30:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82BD32067B
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 14:30:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82BD32067B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=canonical.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B9866B0003; Fri,  6 Sep 2019 10:30:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16A066B0006; Fri,  6 Sep 2019 10:30:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07F356B0007; Fri,  6 Sep 2019 10:30:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0065.hostedemail.com [216.40.44.65])
	by kanga.kvack.org (Postfix) with ESMTP id DB8C16B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 10:30:14 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 7195F181AC9B4
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 14:30:14 +0000 (UTC)
X-FDA: 75904730748.20.bone42_1f25048553f3d
X-HE-Tag: bone42_1f25048553f3d
X-Filterd-Recvd-Size: 1933
Received: from youngberry.canonical.com (youngberry.canonical.com [91.189.89.112])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 14:30:13 +0000 (UTC)
Received: from 1.general.cking.uk.vpn ([10.172.193.212] helo=localhost)
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.76)
	(envelope-from <colin.king@canonical.com>)
	id 1i6FFc-0005RF-IG; Fri, 06 Sep 2019 14:30:12 +0000
From: Colin King <colin.king@canonical.com>
To: Hugh Dickins <hughd@google.com>,
	linux-mm@kvack.org
Cc: kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm/shmem.c: make array 'values' static const, makes object smaller
Date: Fri,  6 Sep 2019 15:30:12 +0100
Message-Id: <20190906143012.28698-1-colin.king@canonical.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Colin Ian King <colin.king@canonical.com>

Don't populate the array 'values' on the stack but instead make it
static const. Makes the object code smaller by 111 bytes.

Before:
   text	   data	    bss	    dec	    hex	filename
 108612	  11169	    512	 120293	  1d5e5	mm/shmem.o

After:
   text	   data	    bss	    dec	    hex	filename
 108437	  11233	    512	 120182	  1d576	mm/shmem.o

(gcc version 9.2.1, amd64)

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 mm/shmem.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 77d2df011c0e..30e1de87bdca 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3934,7 +3934,7 @@ int __init shmem_init(void)
 static ssize_t shmem_enabled_show(struct kobject *kobj,
 		struct kobj_attribute *attr, char *buf)
 {
-	int values[] =3D {
+	static const int values[] =3D {
 		SHMEM_HUGE_ALWAYS,
 		SHMEM_HUGE_WITHIN_SIZE,
 		SHMEM_HUGE_ADVISE,
--=20
2.20.1


