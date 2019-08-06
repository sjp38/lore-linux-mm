Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE0D8C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:29:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 742D32089E
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:29:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="rY7AczG1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 742D32089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B0696B0277; Tue,  6 Aug 2019 19:29:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 187126B0278; Tue,  6 Aug 2019 19:29:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09ED86B0279; Tue,  6 Aug 2019 19:29:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E0FCA6B0277
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 19:29:33 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id s25so77145790qkj.18
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 16:29:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=vaN7rKwbfKjoIgnB/iuhSOxVfS16dMa4sqOfbzb5FXs=;
        b=QLVOrp0CYGI2IEjzI37JApdNO4kyySFV8tltR+l85tgXOVrtpMewpxCbKXzTfKvghR
         HjlFPnAndiD+GWjxfZMP2+SwEZFws1lYAgpeudGLlHMHid3/6toW7BSxDlGrisJDx2Na
         1FgOPon8bUNd3QrY4S65XUcgq8F31+vr7ck+bjxolllxH+C9XmoGb411c/YrU89dQX/1
         T1wg3KHAYha2PoetM9lAmQF3zRGz9uG3eFvG8vwyXMED4bw6q7OcqwKDQTE5JGyROm5y
         eX1zv+1E7ywGwYvAvTUaoBi738LjizVPuhSbeRT5ZfgXf43WD1nyJWBKMtfLMlBDMUdm
         R4WA==
X-Gm-Message-State: APjAAAV9f5e3+uNbFre6zerqX/MOR59KDZ5Iqrt1FiB65hBa3sncqZ8Z
	TnilSShxD4kuoCHSAeWcDi/pxRZc+T8TXoxV6YMNFKHRhvdHWE4+DJzIDyEHl027Y6FWaI9Cg9T
	xOwsRawhBzmkev7PjdsPfnNkzZ9H3nETStliCZrpjJyt62/zSgfKM0MiArQ1+PmSvDg==
X-Received: by 2002:ac8:32a1:: with SMTP id z30mr5573339qta.117.1565134173710;
        Tue, 06 Aug 2019 16:29:33 -0700 (PDT)
X-Received: by 2002:ac8:32a1:: with SMTP id z30mr5573298qta.117.1565134172857;
        Tue, 06 Aug 2019 16:29:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565134172; cv=none;
        d=google.com; s=arc-20160816;
        b=P5/G8nLzCG5o0lx13y+ystq5QXi5CJG4CDcguojB/f7m7xvBO1/DIE74MRjAUvboTk
         y8hFJmRUHKb/QAlkI/WKRpevS0XYrw3eqjtjUJGq4X/+OFLNU7fLrwi6ZanFtladHOZJ
         ZgYdijGm2ZpSXXcyx3ixeheYeBDNzKV9oPihsZRtEcvssp6jmDiKKMAsDj9m0Trou9il
         3ZajrzCljW/RnRfw2d8DA6ojeyMAWfI9UhRvfxIQLZA7gtqLnnalzysxZ65el7hA4GVC
         snXbBRqQYfAP2/t54djuSlzorlECnQM8DjPc5QSgb8QB4trvk3VF8r87N/cXz95iL0C2
         fktA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=vaN7rKwbfKjoIgnB/iuhSOxVfS16dMa4sqOfbzb5FXs=;
        b=rMf8NE8f0fYcVMRpYFY8H068YUA4PxiVjiebFSWxUVLkIUwJg05qTq6W0cxTLs/Nzq
         x0FtU0EzvTjbe9wTCITqT4LIgUZ0AyB1BKPLGz/5ODBa7+ohwMNhRrGW7fwz6074ljOg
         oJff8Zf/+fo0tp3OmZ+Hu08DDZ+gyB9jfNH5lTBN47c+w9LfN8/0XEt97pDkNmKhj0H6
         1dz74sbuMKNKoPjli+oUkUBBYRf0N+NRGsKmpozy4Iqgtcts+nD4e3gHYgBXS3aci6X9
         sVOmyv602VNGuAphBJ3WJFMQNUs0symUW7ecDr6QSiHrn7ZGJmodASB7H8vN89/P6NhY
         OWlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=rY7AczG1;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 56sor115193705qtp.70.2019.08.06.16.29.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 16:29:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=rY7AczG1;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=vaN7rKwbfKjoIgnB/iuhSOxVfS16dMa4sqOfbzb5FXs=;
        b=rY7AczG1FCwGJsA+DlEFYA6NqwEvVQrAZ1R2msA3DPc+6J0zkUJCdfAGdmzfpvgpYx
         3K0WQn8pzzLbfVba0bwpFoyacvzCz8SIJrJL6qvatJBN92kmfjTg8hFDeiNh3cT9AwFj
         5DMhh8RQafKaePDtQqOwRZcCS52tMeCFOlPqu+s4+cS78mZLbcsq/upAwi7jLzzpDMjY
         ZVmlBV8tQanVRg3+YJd/LnbSKwtByr3UedZShGBzkfXL8W6Vcgc5ZIgFb0hRxy+TpBVW
         WbwJ8C+YRQMP/AJU7oI9137oxa9HBO8Ug1gDuPNlLNxCSfIJ3g6USFsjbNRqI6ldTlZP
         qXVA==
X-Google-Smtp-Source: APXvYqzHOhtFD51Ozqo9rIyIvLLP2B00cgCyhC/zh6NbzIA1hqylvEi7fHYtd61G6LqbU8Y0DsBhfQ==
X-Received: by 2002:ac8:25c2:: with SMTP id f2mr5575755qtf.164.1565134172515;
        Tue, 06 Aug 2019 16:29:32 -0700 (PDT)
Received: from ovpn-120-159.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id r17sm40257691qtf.26.2019.08.06.16.29.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 06 Aug 2019 16:29:31 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: arnd@arndb.de,
	kirill.shutemov@linux.intel.com,
	mhocko@suse.com,
	jgg@ziepe.ca,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH v2] asm-generic: fix variable 'p4d' set but not used
Date: Tue,  6 Aug 2019 19:29:17 -0400
Message-Id: <20190806232917.881-1-cai@lca.pw>
X-Mailer: git-send-email 2.20.1 (Apple Git-117)
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A compiler throws a warning on an arm64 system since the
commit 9849a5697d3d ("arch, mm: convert all architectures to use
5level-fixup.h"),

mm/kasan/init.c: In function 'kasan_free_p4d':
mm/kasan/init.c:344:9: warning: variable 'p4d' set but not used
[-Wunused-but-set-variable]
 p4d_t *p4d;
        ^~~

because p4d_none() in "5level-fixup.h" is compiled away while it is a
static inline function in "pgtable-nopud.h". However, if converted
p4d_none() to a static inline there, powerpc would be unhappy as it
reads those in assembler language in
"arch/powerpc/include/asm/book3s/64/pgtable.h", so it needs to skip
assembly include for the static inline C function. While at it,
converted a few similar functions to be consistent with the ones in
"pgtable-nopud.h".

Signed-off-by: Qian Cai <cai@lca.pw>
---

v2: Convert them to static inline functions.

 include/asm-generic/5level-fixup.h | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/include/asm-generic/5level-fixup.h b/include/asm-generic/5level-fixup.h
index bb6cb347018c..f6947da70d71 100644
--- a/include/asm-generic/5level-fixup.h
+++ b/include/asm-generic/5level-fixup.h
@@ -19,9 +19,24 @@
 
 #define p4d_alloc(mm, pgd, address)	(pgd)
 #define p4d_offset(pgd, start)		(pgd)
-#define p4d_none(p4d)			0
-#define p4d_bad(p4d)			0
-#define p4d_present(p4d)		1
+
+#ifndef __ASSEMBLY__
+static inline int p4d_none(p4d_t p4d)
+{
+	return 0;
+}
+
+static inline int p4d_bad(p4d_t p4d)
+{
+	return 0;
+}
+
+static inline int p4d_present(p4d_t p4d)
+{
+	return 1;
+}
+#endif
+
 #define p4d_ERROR(p4d)			do { } while (0)
 #define p4d_clear(p4d)			pgd_clear(p4d)
 #define p4d_val(p4d)			pgd_val(p4d)
-- 
2.20.1 (Apple Git-117)

