Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7F21C49ED6
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B068521A4A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="hJiNQQMh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B068521A4A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C66876B000E; Mon,  9 Sep 2019 14:12:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC3866B0010; Mon,  9 Sep 2019 14:12:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A16166B0266; Mon,  9 Sep 2019 14:12:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0147.hostedemail.com [216.40.44.147])
	by kanga.kvack.org (Postfix) with ESMTP id 808916B000E
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 14:12:35 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 3221552D6
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:35 +0000 (UTC)
X-FDA: 75916177470.10.run01_6dd7f642f112a
X-HE-Tag: run01_6dd7f642f112a
X-Filterd-Recvd-Size: 4622
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:34 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id u40so17261253qth.11
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 11:12:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9qwJvK7duEPa5cSydJwLuayx187fiYj4pOWC7XOD35U=;
        b=hJiNQQMhPzUeNhjSqA+wl+M2Yw4VzmLAzetQQIh1yJcVnbibJdozQMUJIPTj7G1fZ5
         uIcSVRVD7sQv4/zb3vvoXmG7nEkgaDTeuvoEu2B5hEQ4HKyKvqCdxkrMNxnLQvbnC5Sp
         GXJFdIB9Aa+WwqYBwe5OAvMNEHi0mE0MDeX0ZPZjHb8snLd1akNp9JPJJYPCGkMalc8q
         KUixyhfh6ehZRO08DryaR+QFPF2S0018x6Gv5fzx8kXs+kuCJp2nCeGP2cJBD0372qDa
         S1kzC6KQRbcG17aW6isKu0YCKQmeUiKgxNFdBtuyymq/m8jbblhdUBGwoKmff1pBx6J7
         /Y0w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=9qwJvK7duEPa5cSydJwLuayx187fiYj4pOWC7XOD35U=;
        b=Bo2lyNNYBW7fgYFfHvfPqGAZWHY+ugRvdcsFC6OaT91L0rWnK6e/cH2xcC6U9RViCz
         lvu8/MufR6Gblu27p6Pip5hq0DnYZwcNTm0lj9xNsjZ1rciUzrpHlBn+8Mvxp2nJ8Qly
         OHNlW6V8u1NjyC2Miqn6qyxpDBS0VNIskIa4UA+/vjDPmWZ9WRNHp/odHmss7d43dm7C
         Gu6/utQ/pe1CqB/QPGtxGLiYBRbicKJS88gPV45/zXIJ8TnykifzRwYBcdS7XQkADWZX
         BewcWq6rmw00TSsbRe5RuRd6/DhN37bC01qEoYHPS33Q8KyYCikbnbfirTg/RhDoq/mb
         09ww==
X-Gm-Message-State: APjAAAX46MwCvzgfwG+rzv+okVdP48IWKHt6nV91myN5cjoSIe9Gi3ZQ
	u7KWNXsMN3bjlgtoF1uL/uOYWw==
X-Google-Smtp-Source: APXvYqz8CjF5wzOFrAWFe3y7s/Lo+3E4+zqXPfUNMu+qW08GhYxza7uSUBke5A6jwxTbDkv2QIy0jg==
X-Received: by 2002:a0c:9665:: with SMTP id 34mr15164929qvy.223.1568052754025;
        Mon, 09 Sep 2019 11:12:34 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q8sm5611310qtj.76.2019.09.09.11.12.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 11:12:33 -0700 (PDT)
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
Subject: [PATCH v4 07/17] arm64: hibernate: add PUD_SECT_RDONLY
Date: Mon,  9 Sep 2019 14:12:11 -0400
Message-Id: <20190909181221.309510-8-pasha.tatashin@soleen.com>
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

There is PMD_SECT_RDONLY that is used in pud_* function which is confusin=
g.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Acked-by: James Morse <james.morse@arm.com>
---
 arch/arm64/include/asm/pgtable-hwdef.h | 1 +
 arch/arm64/kernel/hibernate.c          | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/include/asm/pgtable-hwdef.h b/arch/arm64/include/=
asm/pgtable-hwdef.h
index db92950bb1a0..dcb4f13c7888 100644
--- a/arch/arm64/include/asm/pgtable-hwdef.h
+++ b/arch/arm64/include/asm/pgtable-hwdef.h
@@ -110,6 +110,7 @@
 #define PUD_TABLE_BIT		(_AT(pudval_t, 1) << 1)
 #define PUD_TYPE_MASK		(_AT(pudval_t, 3) << 0)
 #define PUD_TYPE_SECT		(_AT(pudval_t, 1) << 0)
+#define PUD_SECT_RDONLY		(_AT(pudval_t, 1) << 7)		/* AP[2] */
=20
 /*
  * Level 2 descriptor (PMD).
diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.=
c
index 750ecc7f2cbe..da2b3c5e94cb 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -436,7 +436,7 @@ static int copy_pud(pgd_t *dst_pgdp, pgd_t *src_pgdp,=
 unsigned long start,
 				return -ENOMEM;
 		} else {
 			set_pud(dst_pudp,
-				__pud(pud_val(pud) & ~PMD_SECT_RDONLY));
+				__pud(pud_val(pud) & ~PUD_SECT_RDONLY));
 		}
 	} while (dst_pudp++, src_pudp++, addr =3D next, addr !=3D end);
=20
--=20
2.23.0


