Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA50FC4740C
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84A08218DE
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="OkCmWbda"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84A08218DE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5DF06B0007; Mon,  9 Sep 2019 14:12:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0F506B0008; Mon,  9 Sep 2019 14:12:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD5506B000A; Mon,  9 Sep 2019 14:12:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0236.hostedemail.com [216.40.44.236])
	by kanga.kvack.org (Postfix) with ESMTP id A90D86B0007
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 14:12:28 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 14B00181AC9B4
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:28 +0000 (UTC)
X-FDA: 75916177176.06.son80_6cc8af6479060
X-HE-Tag: son80_6cc8af6479060
X-Filterd-Recvd-Size: 4795
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:27 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id g4so17287898qtq.7
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 11:12:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KdFLASV7D2idWllIjItORA3EXDrjQlb3wnbM2/KPLUA=;
        b=OkCmWbdatFX5LAIn2tZSLcvkwIY8ATYEygi2Y5l77xTfEmsig7FuHjhR+Tc515QvuB
         euMog6/tyZCybSHTwlh79lmWstJtQD3RSy5kH+1xIfPremKMTqJWefDoRzxNP2TLUsUs
         A8mnkxLDs8vT8FE9iLekjK4ByYIMB1NN3YTPldP3X2f9sUKe/mLymg0KFvbKoyLBs/Gn
         j9lDolC3WKF+dc5DLnUZsHk8vVHh9Gj4g3oIHklgpDlJwdONuTr8iJNBwEwkKdeX1KU4
         g1KI3/6zAlekor5jSiDFbhluVvtrCqObj12PpnCxo2VKSdot0KUik0DDJKcvZWQxzbaN
         LhxQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=KdFLASV7D2idWllIjItORA3EXDrjQlb3wnbM2/KPLUA=;
        b=eeYp7joeTTAZhuD8sSo0gfEtgt1260BN523gHEwrs+fCJd4zbMh6ZkcJOJ+Vs+gceK
         nb1iP+Ocgk0LXhZb0AF6wh4YtuEIHxTt19gLBB11uRtVvC5oc+UWV0U4SZ72rjQ+cOW8
         97NK/lW7jVby29dGvpoD9RK4PyYFzIUWAO+kpjAil3VDOrqXbpuGZS6jfYDVu0f/YXUc
         j0prhppi5ebLzDRPuuBp3FeetIE7OrirVOC4FrEeebUOzUG5uI0KstJAtAFIvNuGkmIO
         ydBdw6/3PVI++53zwRiiBmzbXAi3Bp+c97v3eHul8FR9wd+tY/GFLa2jPj06RpzSL50W
         PDJw==
X-Gm-Message-State: APjAAAVvWvtquPsl/z1+xgVHjsgV2UHqhSVPKLa/XKHqJKP8NjV+O7oY
	V81H1SzCPG/6EDp88G5aO3AOJQ==
X-Google-Smtp-Source: APXvYqwN9aenhg2yxq0xot4VzXYd6PfSrS/JrN5n4RjN+y0s2BVwk+1HvDraVw9P1etriXpA8qtInA==
X-Received: by 2002:a0c:e64e:: with SMTP id c14mr15415087qvn.17.1568052746853;
        Mon, 09 Sep 2019 11:12:26 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q8sm5611310qtj.76.2019.09.09.11.12.25
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 11:12:26 -0700 (PDT)
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
Subject: [PATCH v4 02/17] arm64: hibernate: pass the allocated pgdp to ttbr0
Date: Mon,  9 Sep 2019 14:12:06 -0400
Message-Id: <20190909181221.309510-3-pasha.tatashin@soleen.com>
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

ttbr0 should be set to the beginning of pgdp, however, currently
in create_safe_exec_page it is set to pgdp after pgd_offset_raw(),
which works by accident.

Fixes: 0194e760f7d2 ("arm64: hibernate: avoid potential TLB conflict")

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/kernel/hibernate.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.=
c
index 9341fcc6e809..025221564252 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -201,6 +201,7 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
 				 gfp_t mask)
 {
 	int rc =3D 0;
+	pgd_t *trans_pgd;
 	pgd_t *pgdp;
 	pud_t *pudp;
 	pmd_t *pmdp;
@@ -215,7 +216,8 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
 	memcpy((void *)dst, src_start, length);
 	__flush_icache_range(dst, dst + length);
=20
-	pgdp =3D pgd_offset_raw(allocator(mask), dst_addr);
+	trans_pgd =3D allocator(mask);
+	pgdp =3D pgd_offset_raw(trans_pgd, dst_addr);
 	if (pgd_none(READ_ONCE(*pgdp))) {
 		pudp =3D allocator(mask);
 		if (!pudp) {
@@ -262,7 +264,7 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
 	 */
 	cpu_set_reserved_ttbr0();
 	local_flush_tlb_all();
-	write_sysreg(phys_to_ttbr(virt_to_phys(pgdp)), ttbr0_el1);
+	write_sysreg(phys_to_ttbr(virt_to_phys(trans_pgd)), ttbr0_el1);
 	isb();
=20
 	*phys_dst_addr =3D virt_to_phys((void *)dst);
--=20
2.23.0


