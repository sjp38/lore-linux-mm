Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2A68C3A5A5
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 11:22:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC42121882
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 11:22:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="lJn2ZoGm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC42121882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 609376B000D; Mon,  2 Sep 2019 07:22:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5913C6B000E; Mon,  2 Sep 2019 07:22:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47FF86B0010; Mon,  2 Sep 2019 07:22:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0005.hostedemail.com [216.40.44.5])
	by kanga.kvack.org (Postfix) with ESMTP id 2448B6B000D
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 07:22:10 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id BC1AC824CA2A
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 11:22:09 +0000 (UTC)
X-FDA: 75889741578.02.owner84_2fed5700c0343
X-HE-Tag: owner84_2fed5700c0343
X-Filterd-Recvd-Size: 5696
Received: from mail-pl1-f194.google.com (mail-pl1-f194.google.com [209.85.214.194])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 11:22:09 +0000 (UTC)
Received: by mail-pl1-f194.google.com with SMTP id f19so6503931plr.3
        for <linux-mm@kvack.org>; Mon, 02 Sep 2019 04:22:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=rhvVAb+7J0RMzU60BoXrtVVNGscRpJk5bY5+hc+pgTs=;
        b=lJn2ZoGmqXvNOJ2GxqOHlg6gynw3icF854gnf2fdkeE0C1KypDYUziQiRDkZOFXzSt
         zK6v1cmSzkPiqdxZzYsmcE9mgSUk9zesoGV/S6xbSjxAnTZOWTpnmGigvZ+QfyuOa6ph
         ngh/RxBH/bEhzFLW53FQ4dmuIPmMmMb9Ti82U=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=rhvVAb+7J0RMzU60BoXrtVVNGscRpJk5bY5+hc+pgTs=;
        b=hVFVs9+ObmldFkkvOXR68o0zvTN1ecCywB7ejL27/B7aUn3BJTWcEspx25h7MV5qr1
         F4TWrIoQoPFbHtex+uKlhTJGX3LFaOamjybuWSNQkglE+K8emreA8gNGb+94I/OgB48v
         7dnOCEVB9qvsX37BQsNZZ8U9Q5+vY1Qq1W4ksJmQZl8n84zb2OcbK09lyibCkoF1qKa5
         acUZnPRpXqaLHfgzed2ThAYmXUZ4riVqg2vGqLmW0QqLAePHHY1x2s8QWcHrKrK0/Fvb
         /CMUGIvhijggD5dPXJSmQ/TJDWWTKqkqzUGiPa4paz4J5xKl3jtWGxjKH/pGdUj9J1Ez
         OYWg==
X-Gm-Message-State: APjAAAU6/XoWn8/UGAllCdo8r0Oqt0qGmekxEuOt4oL0xiHLNGhWsmHK
	2SEZ9RYCsqz2Pr2ltxhMEe2p4g==
X-Google-Smtp-Source: APXvYqx8sWsJ0Dzj+XlOGkClIeselhraeNCbICc/NGLkgtHjuqQppEXsadh9Ra2gh550ahw6zC+osQ==
X-Received: by 2002:a17:902:74c7:: with SMTP id f7mr25317727plt.263.1567423328350;
        Mon, 02 Sep 2019 04:22:08 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id x10sm11662494pjo.4.2019.09.02.04.22.06
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Sep 2019 04:22:07 -0700 (PDT)
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
Subject: [PATCH v6 5/5] kasan debug: track pages allocated for vmalloc shadow
Date: Mon,  2 Sep 2019 21:20:28 +1000
Message-Id: <20190902112028.23773-6-dja@axtens.net>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190902112028.23773-1-dja@axtens.net>
References: <20190902112028.23773-1-dja@axtens.net>
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
index 0b5141108cdc..fae3cf4ab23a 100644
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
@@ -827,6 +831,7 @@ static int kasan_depopulate_vmalloc_pte(pte_t *ptep, =
unsigned long addr,
 	if (likely(!pte_none(*ptep))) {
 		pte_clear(&init_mm, addr, ptep);
 		free_page(page);
+		vmalloc_shadow_pages--;
 	}
 	spin_unlock(&init_mm.page_table_lock);
=20
@@ -882,4 +887,25 @@ void kasan_release_vmalloc(unsigned long start, unsi=
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


