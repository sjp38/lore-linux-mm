Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F358C4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF05921924
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="nnzdApBl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF05921924
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A42016B000A; Mon,  9 Sep 2019 14:12:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9561F6B000C; Mon,  9 Sep 2019 14:12:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CE976B000D; Mon,  9 Sep 2019 14:12:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0243.hostedemail.com [216.40.44.243])
	by kanga.kvack.org (Postfix) with ESMTP id 586896B000A
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 14:12:31 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id EC70D180AD802
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:30 +0000 (UTC)
X-FDA: 75916177260.13.suit23_6d3551e612d07
X-HE-Tag: suit23_6d3551e612d07
X-Filterd-Recvd-Size: 6221
Received: from mail-qt1-f196.google.com (mail-qt1-f196.google.com [209.85.160.196])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:30 +0000 (UTC)
Received: by mail-qt1-f196.google.com with SMTP id r5so17313395qtd.0
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 11:12:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PMN+GU/7lAwuo7DCEIP2WVoBijVCk7hpbqQ7uFmtqns=;
        b=nnzdApBloMLNe7CmaSyIXPwdwXUub97dhH0hmTNuPhU6Ey5v2IK6XwrSriwQ8EMtik
         1vrTnTVLsxI946LCFlzno1fZjJbbkSBdiwKX/O1V2Sr23i93JseUgZz92ReGWyU9xzMz
         5PnosW9KUenjWvGEQg1FYBtiL4AY/NQ5R2BoydvlYSWk78rThpghy/DJwC9veyytWXCv
         J6VATeAnl1BI6kHItkqSnWP4w0jL/n5QNSwz8LSXfEgxN1LcVaHcptxnHyozclpwZbXv
         t4Bv5epj9+nYTFy0S8Q1O1I/adisDjKUjth8bD3anE6TV0dCTJwQFLgiUbyM23E4rPs4
         vGxw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=PMN+GU/7lAwuo7DCEIP2WVoBijVCk7hpbqQ7uFmtqns=;
        b=cPWo4Vxm5F1SfEW6Gf9Lg4qWIlu9ue4YunbG32iBFzFc8G5CiL9nw6HSyIiRH5meoK
         2IY3e2xHikyHSdpVxO8S1aXhba4bBV65cCherDchNYhWdQBII0vKrA1AXfuJEK5hogBx
         HKbxU/gRSVQU7kd69Jy31CuC8xNv3adPvs6Nzn/NMJNuhFyBF1CIa/RSaJqgDDJrhXfz
         tjfE+dPbYG3CSf7NmPD/Mmzb0y2Rxgb+ODz52kbfc9qcXUbEjBqOGBva17vuoXANR9E4
         AznDBvTx+FXAC1wRqyUz3ADuPJpDLi4yOME3lfFk0vetKx7e8a1w3hXXwuQOGVO0csJb
         L7FA==
X-Gm-Message-State: APjAAAXSZqvWJ/9EEGssuGfs6VPn0oMK8nzJVQwSeX8hJISStWwty05E
	9bk/ybcYsWwjTb7yPcYUfQugz28RajiTdw==
X-Google-Smtp-Source: APXvYqz6jhv4a/IfFo65uSy2aKVphPkzU4Qff5D49UQCU1mAfkT1Y9m5gUkUa74hm3EqOo/yODu9Uw==
X-Received: by 2002:ad4:4441:: with SMTP id l1mr15336417qvt.7.1568052749777;
        Mon, 09 Sep 2019 11:12:29 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q8sm5611310qtj.76.2019.09.09.11.12.28
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 11:12:29 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	ebiederm@xmission.com,
	kexec@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	corbet@lwn.net,
	catalin.marinas@arm.com,
	will@kernel.org,
	linux-arm-kernel@lists.infradead.org,
	marc.zyngier@arm.com,
	james.morse@arm.com,
	vladimir.murzin@arm.com,
	matthias.bgg@gmail.com,
	bhsharma@redhat.com,
	linux-mm@kvack.org,
	mark.rutland@arm.com
Subject: [PATCH v4 04/17] arm64: hibernate: use get_safe_page directly
Date: Mon,  9 Sep 2019 14:12:08 -0400
Message-Id: <20190909181221.309510-5-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190909181221.309510-1-pasha.tatashin@soleen.com>
References: <20190909181221.309510-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

create_safe_exec_page() uses hibernate's allocator to create a set of pag=
e
table to map a single page that will contain the relocation code.

Remove the allocator related arguments, and use get_safe_page directly, a=
s
it is done in other local functions in this file to simplify function
prototype.

Removing this function pointer makes it easier to refactor the code later=
.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/kernel/hibernate.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.=
c
index 227cc26720f7..47a861e0cb0c 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -196,9 +196,7 @@ EXPORT_SYMBOL(arch_hibernation_header_restore);
  */
 static int create_safe_exec_page(void *src_start, size_t length,
 				 unsigned long dst_addr,
-				 phys_addr_t *phys_dst_addr,
-				 void *(*allocator)(gfp_t mask),
-				 gfp_t mask)
+				 phys_addr_t *phys_dst_addr)
 {
 	int rc =3D 0;
 	pgd_t *trans_pgd;
@@ -206,7 +204,7 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
 	pud_t *pudp;
 	pmd_t *pmdp;
 	pte_t *ptep;
-	unsigned long dst =3D (unsigned long)allocator(mask);
+	unsigned long dst =3D get_safe_page(GFP_ATOMIC);
=20
 	if (!dst) {
 		rc =3D -ENOMEM;
@@ -216,7 +214,7 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
 	memcpy((void *)dst, src_start, length);
 	__flush_icache_range(dst, dst + length);
=20
-	trans_pgd =3D allocator(mask);
+	trans_pgd =3D (void *)get_safe_page(GFP_ATOMIC);
 	if (!trans_pgd) {
 		rc =3D -ENOMEM;
 		goto out;
@@ -224,7 +222,7 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
=20
 	pgdp =3D pgd_offset_raw(trans_pgd, dst_addr);
 	if (pgd_none(READ_ONCE(*pgdp))) {
-		pudp =3D allocator(mask);
+		pudp =3D (void *)get_safe_page(GFP_ATOMIC);
 		if (!pudp) {
 			rc =3D -ENOMEM;
 			goto out;
@@ -234,7 +232,7 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
=20
 	pudp =3D pud_offset(pgdp, dst_addr);
 	if (pud_none(READ_ONCE(*pudp))) {
-		pmdp =3D allocator(mask);
+		pmdp =3D (void *)get_safe_page(GFP_ATOMIC);
 		if (!pmdp) {
 			rc =3D -ENOMEM;
 			goto out;
@@ -244,7 +242,7 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
=20
 	pmdp =3D pmd_offset(pudp, dst_addr);
 	if (pmd_none(READ_ONCE(*pmdp))) {
-		ptep =3D allocator(mask);
+		ptep =3D (void *)get_safe_page(GFP_ATOMIC);
 		if (!ptep) {
 			rc =3D -ENOMEM;
 			goto out;
@@ -530,8 +528,7 @@ int swsusp_arch_resume(void)
 	 */
 	rc =3D create_safe_exec_page(__hibernate_exit_text_start, exit_size,
 				   (unsigned long)hibernate_exit,
-				   &phys_hibernate_exit,
-				   (void *)get_safe_page, GFP_ATOMIC);
+				   &phys_hibernate_exit);
 	if (rc) {
 		pr_err("Failed to create safe executable page for hibernate_exit code.=
\n");
 		goto out;
--=20
2.23.0


