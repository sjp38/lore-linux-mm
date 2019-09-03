Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98C4EC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 14:56:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E12D2377B
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 14:56:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="LXzNdZWa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E12D2377B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 108606B0010; Tue,  3 Sep 2019 10:56:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BA6D6B0269; Tue,  3 Sep 2019 10:56:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEA5C6B026A; Tue,  3 Sep 2019 10:56:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0217.hostedemail.com [216.40.44.217])
	by kanga.kvack.org (Postfix) with ESMTP id CECC26B0010
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 10:56:07 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 7A7F9AF79
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 14:56:07 +0000 (UTC)
X-FDA: 75893909574.20.vase96_527bb93ab2817
X-HE-Tag: vase96_527bb93ab2817
X-Filterd-Recvd-Size: 5622
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 14:56:06 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id y9so10947602pfl.4
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 07:56:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=vF6m0g42G8C15Kjxq7JM+Zo7viFkQMObl5+b/f7Khts=;
        b=LXzNdZWazMK6zy0lx9YtBYbXF9X6k/ujNzvt18aBdOOv3v25BsWv4Wq/F1h+j/+f75
         nBnFt6ymLCbGO1vy5RHkDwGov4Jjo0Cgc0ZoZ5V6PBdUG4JRxf84mM0915iQPHCfkFR0
         cD+DOmuxV6yIJsG+RC2TZuWoJ/Y6it1TksSws=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=vF6m0g42G8C15Kjxq7JM+Zo7viFkQMObl5+b/f7Khts=;
        b=RiUoWM9HI4qjLqnVHr+LhBjJSaNrtM/HbCk7bZdUU03EnUX4nAD1Y+04QqPYg7cKeu
         babrYZ8XMRcF8Y+bno54o5UefPyYHUo755xDv9LF8KesYtUukkl1xF4GWbzg8MxhDnfG
         l9rCL36KlL6ATD6bAkmcIBsp9Ne+N1o3i9TrFwaIQ77K8NLQKOdYseb+ZRJWgMjUXGuw
         g2OmSUXvCdFbWoFipApcDjk8OsIKeOhAOcwH+QZtz3MOfQXWBjo7jHwucqVFESr5ZNnc
         eCnk1SqOzZCWP1eg3f3ZJQdfPEtvL8fb/8xB0OLzfuAExZbtLQqx+Aadackbn+KIQ0Bm
         qE9w==
X-Gm-Message-State: APjAAAXadvmxXYJ+h4g90X5X3z3w1NhztfqxLze3ueQlT8gTHF5UHfwf
	BPWFok1y/muPvQsG+GGQaevfWg==
X-Google-Smtp-Source: APXvYqy/yahnMfGQMxl26bPPEiAFpA8rUWYVZ8anzToEuFp60PcEjZs5R9s0WyRaFq3Ey75Xj3i90w==
X-Received: by 2002:a63:194f:: with SMTP id 15mr31482111pgz.382.1567522565767;
        Tue, 03 Sep 2019 07:56:05 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id c1sm19943843pfd.117.2019.09.03.07.56.04
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Sep 2019 07:56:05 -0700 (PDT)
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
Subject: [PATCH v7 5/5] kasan debug: track pages allocated for vmalloc shadow
Date: Wed,  4 Sep 2019 00:55:36 +1000
Message-Id: <20190903145536.3390-6-dja@axtens.net>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190903145536.3390-1-dja@axtens.net>
References: <20190903145536.3390-1-dja@axtens.net>
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
index e33cbab83309..e40854512417 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -35,6 +35,7 @@
 #include <linux/vmalloc.h>
 #include <linux/bug.h>
 #include <linux/uaccess.h>
+#include <linux/debugfs.h>
=20
 #include <asm/tlbflush.h>
=20
@@ -750,6 +751,8 @@ core_initcall(kasan_memhotplug_init);
 #endif
=20
 #ifdef CONFIG_KASAN_VMALLOC
+static u64 vmalloc_shadow_pages;
+
 static int kasan_populate_vmalloc_pte(pte_t *ptep, unsigned long addr,
 				      void *unused)
 {
@@ -776,6 +779,7 @@ static int kasan_populate_vmalloc_pte(pte_t *ptep, un=
signed long addr,
 	if (likely(pte_none(*ptep))) {
 		set_pte_at(&init_mm, addr, ptep, pte);
 		page =3D 0;
+		vmalloc_shadow_pages++;
 	}
 	spin_unlock(&init_mm.page_table_lock);
 	if (page)
@@ -829,6 +833,7 @@ static int kasan_depopulate_vmalloc_pte(pte_t *ptep, =
unsigned long addr,
 	if (likely(!pte_none(*ptep))) {
 		pte_clear(&init_mm, addr, ptep);
 		free_page(page);
+		vmalloc_shadow_pages--;
 	}
 	spin_unlock(&init_mm.page_table_lock);
=20
@@ -947,4 +952,25 @@ void kasan_release_vmalloc(unsigned long start, unsi=
gned long end,
 				       (unsigned long)shadow_end);
 	}
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


