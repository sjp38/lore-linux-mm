Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D39ABC3A59D
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:46:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 973FC21019
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:46:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="K3uh07Qn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 973FC21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BB676B0272; Fri, 16 Aug 2019 22:46:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F6096B0273; Fri, 16 Aug 2019 22:46:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 096E56B0274; Fri, 16 Aug 2019 22:46:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0137.hostedemail.com [216.40.44.137])
	by kanga.kvack.org (Postfix) with ESMTP id D5FD86B0272
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 22:46:43 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 88A276D76
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:43 +0000 (UTC)
X-FDA: 75830381886.13.goat09_7981a99321d
X-HE-Tag: goat09_7981a99321d
X-Filterd-Recvd-Size: 4542
Received: from mail-qt1-f196.google.com (mail-qt1-f196.google.com [209.85.160.196])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:43 +0000 (UTC)
Received: by mail-qt1-f196.google.com with SMTP id j15so8155250qtl.13
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 19:46:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RGtrOUupW4z37ipmqcLJyB3m7q6WPq+p9ucEiFhnLcg=;
        b=K3uh07Qn3TrpcWz7z/N+EGQbeyvKel3p7LpHgPxW5XHEjHN0nGfMdgMxXJEwmCcG6B
         nhWCIGqiH1BVHTBUWPfRA9ND8m+l/2KTafHuxqDij7+QKz/6GZD6bCgPhsJWTHE4AHiI
         6QuEh9K7DIQ65DSCwGlbOOE6+FpfL41IRKJgh1HQ6gIEoUzJizo4TtnYl8fFrxPVcgT6
         I/Rh6DFEQ9kD9MkGVP+CrWhb4fozfe+U3YNn6UXqxmwHpiDRJHemP2SO4pOJXNXrs2EC
         j/tgcGrskD3ABV484TSaBLkoWfzEkalgsgMt+pLjBW9D4bLY1lQad/JI8NYEodMP3lxH
         z25g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=RGtrOUupW4z37ipmqcLJyB3m7q6WPq+p9ucEiFhnLcg=;
        b=QSkOIygZSy0a88fiEeYo+HZag/McvgUpbZkF15f7rXmQTMrFl5uSkhJMw/7/zX41W3
         qzQfyDx8LT1LZVnkanhhZ1aPt9113AXYOTM1kUzU/ZxjL/YXj4cix8ANLY5wDimpVvYD
         YRUTdipyB6t0ZGdq91veWHI0gUNWhchGwAy9K8uMGhz2f+60Y+hYgBfWsoF+g4hnAkEl
         wWtfMEbcfK9qI8YoICHk00dt6qrvEAg39HEmfTXYLsHxy0Ug6uQyySsn9YJInCcO5GXM
         0IBfPJvadnQU/qjik30ap5cSQCG3avk+x1S0CollPXR+p0jHnKCncwm5LS+HaWBI6Jlb
         iOtg==
X-Gm-Message-State: APjAAAU60Dra0V9nhwEWnYeTUQleg5z5o/8SqwLnqYdozrq3bbmnkdFj
	E+YJtdGE1nhOis1pY4IBU/5wnw==
X-Google-Smtp-Source: APXvYqxHWuJZxhJoL32IA5dYdauUAj5ZZIoyQiY5axJ7rJ6tklLVzo2+3JJMyaLqd0hjiXW2rE1ZaQ==
X-Received: by 2002:a0c:b786:: with SMTP id l6mr3917888qve.148.1566010002583;
        Fri, 16 Aug 2019 19:46:42 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id o9sm3454657qtr.71.2019.08.16.19.46.41
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Aug 2019 19:46:42 -0700 (PDT)
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
	linux-mm@kvack.org
Subject: [PATCH v2 08/14] arm64, trans_table: add PUD_SECT_RDONLY
Date: Fri, 16 Aug 2019 22:46:23 -0400
Message-Id: <20190817024629.26611-9-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.22.1
In-Reply-To: <20190817024629.26611-1-pasha.tatashin@soleen.com>
References: <20190817024629.26611-1-pasha.tatashin@soleen.com>
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
---
 arch/arm64/include/asm/pgtable-hwdef.h | 1 +
 arch/arm64/mm/trans_table.c            | 2 +-
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
diff --git a/arch/arm64/mm/trans_table.c b/arch/arm64/mm/trans_table.c
index 634293ffb54c..815e40bb1316 100644
--- a/arch/arm64/mm/trans_table.c
+++ b/arch/arm64/mm/trans_table.c
@@ -138,7 +138,7 @@ static int copy_pud(pgd_t *dst_pgdp, pgd_t *src_pgdp,=
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
2.22.1


