Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46535C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00EAB2339F
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="X2bYtpl7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00EAB2339F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B4F96B000C; Wed, 21 Aug 2019 14:32:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8436F6B000D; Wed, 21 Aug 2019 14:32:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 690D26B000E; Wed, 21 Aug 2019 14:32:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0025.hostedemail.com [216.40.44.25])
	by kanga.kvack.org (Postfix) with ESMTP id 45A8D6B000C
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:32:10 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 00214181AC9D3
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:09 +0000 (UTC)
X-FDA: 75847279620.15.smoke58_2ffac37e06530
X-HE-Tag: smoke58_2ffac37e06530
X-Filterd-Recvd-Size: 5875
Received: from mail-qk1-f195.google.com (mail-qk1-f195.google.com [209.85.222.195])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:09 +0000 (UTC)
Received: by mail-qk1-f195.google.com with SMTP id w18so2748375qki.0
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:32:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sBcmTKCPArGqx1dLEuzw7dGqn3biKX2D2IdqnHxnWGU=;
        b=X2bYtpl73i+ZQotUx4rPisykcv7elNg3338iVDx51XS8IAesuAET+FJOq1+cDPHG3r
         9rXZdHhqVDL3/xQGl5vT6Oz1ojz+sochUryLWNC1UkgH72k4uApv4TU3RPAclgoyyqhi
         PtlrcnmGLE9h7VsHDPnkFYU5m0ABJTH/PIiWiIwSHa0+lVdUA+kmwFkX7o0khAOFTlSO
         mjutz0tdYRK2G5NUrq7EhUcZ2mAb37l6c2Nnbno0RHr3dhJsbHYDZXP896fB8kwPSIjI
         1XE3mEsJ/pqIbN/NdSziIya/6qdVEfThdKypQFpVlOqjbOH3B1UilgXm0yfhqpBaYVAs
         eABw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=sBcmTKCPArGqx1dLEuzw7dGqn3biKX2D2IdqnHxnWGU=;
        b=sxOOjn32+dr02PkBBv8amFmCJkfJbvnCYdfcWocnVMfDFYCPogFOTONeNoqAVXP6j8
         dBrCKi2DyUpnxWYSnsOW6ri7QEEqvoEOUlN7Orn2VaKvAMGqDtsEdAdyyD5/bD9/69QU
         iCG2uGRbYOlcqmVq69zXTpAVSF7wy0lYXScRMdbg0oZMnoL4rnJoHEvpQH9Nybme+sD/
         ZRfMWgF7bD09Lqidyl1O3ZkGqNzBChsunb6nvmtWtGNUUVtjuVXNlOhyzn1jmxr6RNlS
         vFrmWsreeCfIIpFxe4nAFwcmIuM8l0ycgf4//CJGglhqAZdX1QkYu2ie7Iu85PiwSZjJ
         7dNw==
X-Gm-Message-State: APjAAAUV6DdYhdfCh88jMPHEKTvrRrihnltlykmRYhpDpcFtOwS1J5kD
	r6CPov5vHObRRUci9aT01v4k+A==
X-Google-Smtp-Source: APXvYqwTD5jDmCNqAlhQx5bPMjXa8Ne5sUA8XkdytBk284LEJsuvSjr3IvAfqjwgKcf+e9prxBD89g==
X-Received: by 2002:a37:6290:: with SMTP id w138mr31111453qkb.139.1566412329038;
        Wed, 21 Aug 2019 11:32:09 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q13sm10443332qkm.120.2019.08.21.11.32.07
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 Aug 2019 11:32:08 -0700 (PDT)
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
Subject: [PATCH v3 02/17] arm64, hibernate: use get_safe_page directly
Date: Wed, 21 Aug 2019 14:31:49 -0400
Message-Id: <20190821183204.23576-3-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190821183204.23576-1-pasha.tatashin@soleen.com>
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

create_safe_exec_page is a local function that uses the
get_safe_page() to allocate page table and pages and one pages
that is getting mapped.

Remove the allocator related arguments, and use get_safe_page
directly, as it is done in other local functions in this
file.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/kernel/hibernate.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.=
c
index 9341fcc6e809..4bb4d17a6a7c 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -196,16 +196,14 @@ EXPORT_SYMBOL(arch_hibernation_header_restore);
  */
 static int create_safe_exec_page(void *src_start, size_t length,
 				 unsigned long dst_addr,
-				 phys_addr_t *phys_dst_addr,
-				 void *(*allocator)(gfp_t mask),
-				 gfp_t mask)
+				 phys_addr_t *phys_dst_addr)
 {
 	int rc =3D 0;
 	pgd_t *pgdp;
 	pud_t *pudp;
 	pmd_t *pmdp;
 	pte_t *ptep;
-	unsigned long dst =3D (unsigned long)allocator(mask);
+	unsigned long dst =3D get_safe_page(GFP_ATOMIC);
=20
 	if (!dst) {
 		rc =3D -ENOMEM;
@@ -215,9 +213,9 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
 	memcpy((void *)dst, src_start, length);
 	__flush_icache_range(dst, dst + length);
=20
-	pgdp =3D pgd_offset_raw(allocator(mask), dst_addr);
+	pgdp =3D pgd_offset_raw((void *)get_safe_page(GFP_ATOMIC), dst_addr);
 	if (pgd_none(READ_ONCE(*pgdp))) {
-		pudp =3D allocator(mask);
+		pudp =3D (void *)get_safe_page(GFP_ATOMIC);
 		if (!pudp) {
 			rc =3D -ENOMEM;
 			goto out;
@@ -227,7 +225,7 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
=20
 	pudp =3D pud_offset(pgdp, dst_addr);
 	if (pud_none(READ_ONCE(*pudp))) {
-		pmdp =3D allocator(mask);
+		pmdp =3D (void *)get_safe_page(GFP_ATOMIC);
 		if (!pmdp) {
 			rc =3D -ENOMEM;
 			goto out;
@@ -237,7 +235,7 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
=20
 	pmdp =3D pmd_offset(pudp, dst_addr);
 	if (pmd_none(READ_ONCE(*pmdp))) {
-		ptep =3D allocator(mask);
+		ptep =3D (void *)get_safe_page(GFP_ATOMIC);
 		if (!ptep) {
 			rc =3D -ENOMEM;
 			goto out;
@@ -523,8 +521,7 @@ int swsusp_arch_resume(void)
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


