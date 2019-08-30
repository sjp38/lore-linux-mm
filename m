Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 001F0C3A5A6
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 00:40:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB0E721670
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 00:40:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="nD1A5jPv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB0E721670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6389B6B0008; Thu, 29 Aug 2019 20:40:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E8576B0010; Thu, 29 Aug 2019 20:40:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D7D56B0266; Thu, 29 Aug 2019 20:40:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0011.hostedemail.com [216.40.44.11])
	by kanga.kvack.org (Postfix) with ESMTP id 2642C6B0008
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 20:40:08 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id CF08A1E093
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 00:40:07 +0000 (UTC)
X-FDA: 75877237254.17.jeans49_5864c210b3c4c
X-HE-Tag: jeans49_5864c210b3c4c
X-Filterd-Recvd-Size: 5669
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com [209.85.215.193])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 00:40:07 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id m3so2514310pgv.13
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 17:40:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=82Q/JFIZnRXp0gOKtGutBaFqGjeRYEXgiO+lMUV240Y=;
        b=nD1A5jPvsIP89nHBMvBHrNI1GqT/PDiCf4jxHaCbxxEnlAXlcBW7mkvaA6ZVlmKfzS
         NkBfs1H94Zz4smL76mncvLsIszMvMwN8JXpr2ZJU31OBYDVyPNcshJZWBWPg9+gdAgSF
         w4aZZ3y1NslYt7ctZc5tXH2Vuybo+Jx53VCXY=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=82Q/JFIZnRXp0gOKtGutBaFqGjeRYEXgiO+lMUV240Y=;
        b=X/pzug1eH1FyuJAQnbuzG/ZPyOoy8y57Y80KiKkO+M7bkT0uPXrbGL62gXnZoiKlzS
         vYadypLADuGn7XgGZ+SEqvggAFzieAVq1bqrI32FXe7Gkzk7BIy4pcyHcm+YWxgv6rK4
         lQKNlPvtpQOwgwFV70GMARAYdpCchIlHiyiAZyD+zI74JOPNTG4gQkI/TIDE5yy49eZa
         M7WXIffkSh3n9NtW/8jw03jDts4/4qhcuyw0+gUuQDH05I25Mx3lU72m6t+C4rPQkqd6
         OfZI2Ma57jmoNB67LpULIHpSeq/26HeMt9lbjaieXfX9pjFD4EGNPt/OKEy9gffb80L5
         2O9w==
X-Gm-Message-State: APjAAAV3q05Zz2jkDScclHx2SI5XP8I3tYJvzTNpVRajviuHp77tVWBd
	B6rsNSSR666EgPnrM/CS3xbK3AXJVRU=
X-Google-Smtp-Source: APXvYqzNoJGYFrsnYDroRSYoteG3iJDXlHgkj88MSgz63Rrn0+nV1EyQWSk/4Z2CmdbFPGnpPD4GHg==
X-Received: by 2002:a63:1908:: with SMTP id z8mr10423041pgl.433.1567125606413;
        Thu, 29 Aug 2019 17:40:06 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id b19sm3452810pgs.10.2019.08.29.17.40.01
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Aug 2019 17:40:05 -0700 (PDT)
From: Daniel Axtens <dja@axtens.net>
To: kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	x86@kernel.org,
	aryabinin@virtuozzo.com,
	glider@google.com,
	luto@kernel.org,
	linux-kernel@vger.kernel.org,
	mark.rutland@arm.com,
	dvyukov@google.com,
	christophe.leroy@c-s.fr
Cc: linuxppc-dev@lists.ozlabs.org,
	gor@linux.ibm.com,
	Daniel Axtens <dja@axtens.net>
Subject: [PATCH v5 5/5] kasan debug: track pages allocated for vmalloc shadow
Date: Fri, 30 Aug 2019 10:38:21 +1000
Message-Id: <20190830003821.10737-6-dja@axtens.net>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190830003821.10737-1-dja@axtens.net>
References: <20190830003821.10737-1-dja@axtens.net>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Provide the current number of vmalloc shadow pages in
/sys/kernel/debug/kasan_vmalloc/shadow_pages.

Signed-off-by: Daniel Axtens <dja@axtens.net>

---

Merging this is probably overkill, but I leave it to the discretion
of the broader community.

On v4 (no dynamic freeing), I saw the following approximate figures
on my test VM:

 - fresh boot: 720
 - after test_vmalloc: ~14000

With v5 (lazy dynamic freeing):

 - boot: ~490-500
 - running modprobe test_vmalloc pushes the figures up to sometimes
    as high as ~14000, but they drop down to ~560 after the test ends.
    I'm not sure where the extra sixty pages are from, but running the
    test repeately doesn't cause the number to keep growing, so I don't
    think we're leaking.
 - with vmap_stack, spawning tasks pushes the figure up to ~4200, then
    some clearing kicks in and drops it down to previous levels again.
---
 mm/kasan/common.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index c12a2e6ecff5..69f32f2857b0 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -35,6 +35,7 @@
 #include <linux/vmalloc.h>
 #include <linux/bug.h>
 #include <linux/uaccess.h>
+#include <linux/debugfs.h>
=20
 #include "kasan.h"
 #include "../slab.h"
@@ -748,6 +749,8 @@ core_initcall(kasan_memhotplug_init);
 #endif
=20
 #ifdef CONFIG_KASAN_VMALLOC
+static u64 vmalloc_shadow_pages;
+
 static int kasan_populate_vmalloc_pte(pte_t *ptep, unsigned long addr,
 				      void *unused)
 {
@@ -774,6 +777,7 @@ static int kasan_populate_vmalloc_pte(pte_t *ptep, un=
signed long addr,
 	if (likely(pte_none(*ptep))) {
 		set_pte_at(&init_mm, addr, ptep, pte);
 		page =3D 0;
+		vmalloc_shadow_pages++;
 	}
 	spin_unlock(&init_mm.page_table_lock);
 	if (page)
@@ -833,6 +837,7 @@ static int kasan_depopulate_vmalloc_pte(pte_t *ptep, =
unsigned long addr,
=20
 	pte_clear(&init_mm, addr, ptep);
 	free_page(page);
+	vmalloc_shadow_pages--;
 	spin_unlock(&init_mm.page_table_lock);
=20
 	return 0;
@@ -887,4 +892,25 @@ void kasan_release_vmalloc(unsigned long start, unsi=
gned long end,
 				    (unsigned long)(shadow_end - shadow_start),
 				    kasan_depopulate_vmalloc_pte, NULL);
 }
+
+static __init int kasan_init_vmalloc_debugfs(void)
+{
+	struct dentry *root, *count;
+
+	root =3D debugfs_create_dir("kasan_vmalloc", NULL);
+	if (IS_ERR(root)) {
+		if (PTR_ERR(root) =3D=3D -ENODEV)
+			return 0;
+		return PTR_ERR(root);
+	}
+
+	count =3D debugfs_create_u64("shadow_pages", 0444, root,
+				   &vmalloc_shadow_pages);
+
+	if (IS_ERR(count))
+		return PTR_ERR(root);
+
+	return 0;
+}
+late_initcall(kasan_init_vmalloc_debugfs);
 #endif
--=20
2.20.1


