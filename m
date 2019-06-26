Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80936C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 13:21:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52DA521670
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 13:21:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52DA521670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEEDE8E0007; Wed, 26 Jun 2019 09:21:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9ED88E0002; Wed, 26 Jun 2019 09:21:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C682C8E0007; Wed, 26 Jun 2019 09:21:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 77C478E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 09:21:33 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b21so3196082edt.18
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 06:21:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=grV5yv5Fb3u3tF2bDQ1i+3jnfG4Y4yNlyHoRzoBCQLU=;
        b=noUpe2Lgq1Wsyn8PYIuSPYe3YPDjgZb4asA02IMAn1hoTbPSEZ598scsVBiITEyqqj
         5krbazhfVg2qeU4eYN/XzsEVCkVZb4XzUEpA7ml5FhGiY6aVaIExqVQvBBihfXctqY3B
         89xdK/Mde3KgJu00KQy9D7QQKw94xuYhV/rhfcmX+ah1JtDIMxB1XyS2nIJtxHb0qNRc
         7tF6BZQRGCmUwPqC3NIcSPUM+GM6wfmVaUYcZfIPbbF1TG/nWSnUDrzXjMvCIQzxxQSf
         xxndq9A72ogvF9y/YGsW1QIdaLt7GpuyvhPP61ZI3ZiP9KL/nZeo4cYiKVr8PQoeQ9Qc
         B9SA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUKSnJQ4HVcWIEGg+oUoChQX0HnZ12graXtcNho4rsvbm6qniZe
	t8CQGrL8YqERWEMxZCkm46piigOv5bjdrj+zcs+CTjuBG/w4RDzFiI3TUj1xit8PL7WzrAJx6Lz
	OTaOKFCekXp4N2gSpVmQ4Qzw+6H6ISsCXhDmxwvviTtH10AEJnAv5RbcKpVIMq3jqUA==
X-Received: by 2002:a50:ad62:: with SMTP id z31mr5317378edc.139.1561555293066;
        Wed, 26 Jun 2019 06:21:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxV3R9WdHdz/UaLcWAhp8e/cpvVaHZ6OeqAT3i1WuoKdFJTojXUxMlUavGJI0Fg2JsteMvm
X-Received: by 2002:a50:ad62:: with SMTP id z31mr5317279edc.139.1561555292145;
        Wed, 26 Jun 2019 06:21:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561555292; cv=none;
        d=google.com; s=arc-20160816;
        b=y84ydCdCFaO41tp18c9fF01G1G5HAwnuoS6RToz952cLLYlWdJSR32cOPa9of2Dj3N
         ZvSEzwa2DT+iXajK0Olz1yY6H7cKPvHtHiB1GXdnLVszzBNOybvXaE9fVj1huCs9QDV+
         PfGIRl7bcOQYQVEbKlGu/KILP3cLzLH2pDcw0R/biAb0qQbn11GuJx8oqjlBrhu+uY0I
         32ZnG7GayPKeyszXn8+eyemfYiUtefTh6IRCQDBiIivZ2axdcWbBgJqmz6Fu7wf7uT5W
         m/Gr4K/vCT3i/TVOAxjK06k9FpUQ3IqWmfzCOgOPXru0Oa7lGdIEyGI8jNwxHGeO5eh3
         mdQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=grV5yv5Fb3u3tF2bDQ1i+3jnfG4Y4yNlyHoRzoBCQLU=;
        b=BrKR5kMYLbh7SkQ1wKkoSYzOS6lcjGGo/rUTb4vP6PrLA+VrR9hgMEIOuPMSuIeXqw
         3oPM95gEMwV++L7HGItSmL+jUhNlrN0dJoIsu/yxAKIpWC2okqkhWVzHgn8mEtTAxb0J
         Du+wvP9D9LUOkQJlPpF5kgnvm0hyYuYUlXmU4+uaseuyBHdrAH+ZPlKJaS3mahc/dq+K
         pyWqSb5riv44uFVo69sqj2Jk73u66zMubI9v9AKp1wREIKa+MrsltSEmZ90soztY+HVE
         1ZAmxJ/w08lhbK+rNMUlYIk0j0d8afcKvCDd0+9ra5ZixMVx66dfWTONhgCvHQeh7Khu
         17hw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id d28si3237306eda.375.2019.06.26.06.21.31
        for <linux-mm@kvack.org>;
        Wed, 26 Jun 2019 06:21:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1D595360;
	Wed, 26 Jun 2019 06:21:31 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.40.140])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 4550F3F71E;
	Wed, 26 Jun 2019 06:21:25 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Nicholas Piggin <npiggin@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org
Subject: [PATCH] powerpc/64s/radix: Define arch_ioremap_p4d_supported()
Date: Wed, 26 Jun 2019 18:51:00 +0530
Message-Id: <1561555260-17335-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Recent core ioremap changes require HAVE_ARCH_HUGE_VMAP subscribing archs
provide arch_ioremap_p4d_supported() failing which will result in a build
failure like the following.

ld: lib/ioremap.o: in function `.ioremap_huge_init':
ioremap.c:(.init.text+0x3c): undefined reference to
`.arch_ioremap_p4d_supported'

This defines a stub implementation for arch_ioremap_p4d_supported() keeping
it disabled for now to fix the build problem.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Nicholas Piggin <npiggin@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-next@vger.kernel.org

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
This has been just build tested and fixes the problem reported earlier.

 arch/powerpc/mm/book3s64/radix_pgtable.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/powerpc/mm/book3s64/radix_pgtable.c b/arch/powerpc/mm/book3s64/radix_pgtable.c
index 8904aa1..c81da88 100644
--- a/arch/powerpc/mm/book3s64/radix_pgtable.c
+++ b/arch/powerpc/mm/book3s64/radix_pgtable.c
@@ -1124,6 +1124,11 @@ void radix__ptep_modify_prot_commit(struct vm_area_struct *vma,
 	set_pte_at(mm, addr, ptep, pte);
 }
 
+int __init arch_ioremap_p4d_supported(void)
+{
+	return 0;
+}
+
 int __init arch_ioremap_pud_supported(void)
 {
 	/* HPT does not cope with large pages in the vmalloc area */
-- 
2.7.4

