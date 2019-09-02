Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A84C2C3A5A7
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 11:22:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6037821882
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 11:22:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="gDXdH1Vz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6037821882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14CF66B000C; Mon,  2 Sep 2019 07:22:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D6A36B000D; Mon,  2 Sep 2019 07:22:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F07CF6B000E; Mon,  2 Sep 2019 07:22:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0049.hostedemail.com [216.40.44.49])
	by kanga.kvack.org (Postfix) with ESMTP id C36AB6B000C
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 07:22:05 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 62A006C37
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 11:22:05 +0000 (UTC)
X-FDA: 75889741410.14.sheet21_2f464cd1e3642
X-HE-Tag: sheet21_2f464cd1e3642
X-Filterd-Recvd-Size: 6759
Received: from mail-pl1-f196.google.com (mail-pl1-f196.google.com [209.85.214.196])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 11:22:04 +0000 (UTC)
Received: by mail-pl1-f196.google.com with SMTP id w11so6530710plp.5
        for <linux-mm@kvack.org>; Mon, 02 Sep 2019 04:22:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=/Pi33Ab5H1THuUOlmFKCqF9xJSMT6s+LImLmp8toPnA=;
        b=gDXdH1Vzt9MxAmqX7AuRJKG5lhNoxBKVnKniwrJl5XzSGvzlnrJnb+p31PYrO9K9gG
         6oKXzhCh06wj46HhNFqV2lhipcEhwXhF2tZ88V/ROZ9ZIxL6YbGKCrH1NnlcBZTiBpbZ
         GPFRkVKygJf7mZNWWmmm8N1pkU1UFrSxNc9LQ=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=/Pi33Ab5H1THuUOlmFKCqF9xJSMT6s+LImLmp8toPnA=;
        b=oVrQcLJPTstbdlKtFgKVvSKE1f+POzs/KapwfWKkeC0DZm6kHWZtVncF2o/yZFZMEF
         STRMw1v4dZLQPMmn1YE0uZPC45tuTlHlq5t0w8JGSkcfI0CfZxwgujTkLlmcZW9Osbwg
         YFR/I3KQuI+0jOOWjoxWQ+gATdkHGCKIYu0HSNhLQt8LU+4San74GmFzU6xaHuDkc+nb
         YUbVXVbWMp8zzX5UjzUG6C9Io7zZ1QlliHaodxT/bq5erAnrutpmsZX8ArczahqrBhMt
         obErao7UxdxQcHsY6Irz0sQks6YEYrOaaHWkM3jf8eTZ6xw+asPuEOBhchr4x0dtYK4z
         f4WA==
X-Gm-Message-State: APjAAAVb6dSDRYuefSfuM3yl0XrCi9iqcJ/17z/ey1fIsRiH38/SHwKB
	QiUUWcJjTQYlFRcJb0NpUDXEGA==
X-Google-Smtp-Source: APXvYqwOuMIC7qhrbPrEee+w2Q+KHHV7BK3R6x7r58fT6LOhqr2EZe5BvG/TJ1wJkhZZ3klGYrUUDQ==
X-Received: by 2002:a17:902:b08f:: with SMTP id p15mr5676763plr.49.1567423323788;
        Mon, 02 Sep 2019 04:22:03 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id i6sm9452487pfq.20.2019.09.02.04.22.02
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Sep 2019 04:22:03 -0700 (PDT)
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
Subject: [PATCH v6 4/5] x86/kasan: support KASAN_VMALLOC
Date: Mon,  2 Sep 2019 21:20:27 +1000
Message-Id: <20190902112028.23773-5-dja@axtens.net>
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

In the case where KASAN directly allocates memory to back vmalloc
space, don't map the early shadow page over it.

We prepopulate pgds/p4ds for the range that would otherwise be empty.
This is required to get it synced to hardware on boot, allowing the
lower levels of the page tables to be filled dynamically.

Acked-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Daniel Axtens <dja@axtens.net>

---
v5: fix some checkpatch CHECK warnings. There are some that remain
    around lines ending with '(': I have not changed these because
    it's consistent with the rest of the file and it's not easy to
    see how to fix it without creating an overlong line or lots of
    temporary variables.

v2: move from faulting in shadow pgds to prepopulating
---
 arch/x86/Kconfig            |  1 +
 arch/x86/mm/kasan_init_64.c | 60 +++++++++++++++++++++++++++++++++++++
 2 files changed, 61 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 2502f7f60c9c..300b4766ccfa 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -134,6 +134,7 @@ config X86
 	select HAVE_ARCH_JUMP_LABEL
 	select HAVE_ARCH_JUMP_LABEL_RELATIVE
 	select HAVE_ARCH_KASAN			if X86_64
+	select HAVE_ARCH_KASAN_VMALLOC		if X86_64
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_MMAP_RND_BITS		if MMU
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS	if MMU && COMPAT
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 296da58f3013..8f00f462709e 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -245,6 +245,51 @@ static void __init kasan_map_early_shadow(pgd_t *pgd=
)
 	} while (pgd++, addr =3D next, addr !=3D end);
 }
=20
+static void __init kasan_shallow_populate_p4ds(pgd_t *pgd,
+					       unsigned long addr,
+					       unsigned long end,
+					       int nid)
+{
+	p4d_t *p4d;
+	unsigned long next;
+	void *p;
+
+	p4d =3D p4d_offset(pgd, addr);
+	do {
+		next =3D p4d_addr_end(addr, end);
+
+		if (p4d_none(*p4d)) {
+			p =3D early_alloc(PAGE_SIZE, nid, true);
+			p4d_populate(&init_mm, p4d, p);
+		}
+	} while (p4d++, addr =3D next, addr !=3D end);
+}
+
+static void __init kasan_shallow_populate_pgds(void *start, void *end)
+{
+	unsigned long addr, next;
+	pgd_t *pgd;
+	void *p;
+	int nid =3D early_pfn_to_nid((unsigned long)start);
+
+	addr =3D (unsigned long)start;
+	pgd =3D pgd_offset_k(addr);
+	do {
+		next =3D pgd_addr_end(addr, (unsigned long)end);
+
+		if (pgd_none(*pgd)) {
+			p =3D early_alloc(PAGE_SIZE, nid, true);
+			pgd_populate(&init_mm, pgd, p);
+		}
+
+		/*
+		 * we need to populate p4ds to be synced when running in
+		 * four level mode - see sync_global_pgds_l4()
+		 */
+		kasan_shallow_populate_p4ds(pgd, addr, next, nid);
+	} while (pgd++, addr =3D next, addr !=3D (unsigned long)end);
+}
+
 #ifdef CONFIG_KASAN_INLINE
 static int kasan_die_handler(struct notifier_block *self,
 			     unsigned long val,
@@ -352,9 +397,24 @@ void __init kasan_init(void)
 	shadow_cpu_entry_end =3D (void *)round_up(
 			(unsigned long)shadow_cpu_entry_end, PAGE_SIZE);
=20
+	/*
+	 * If we're in full vmalloc mode, don't back vmalloc space with early
+	 * shadow pages. Instead, prepopulate pgds/p4ds so they are synced to
+	 * the global table and we can populate the lower levels on demand.
+	 */
+#ifdef CONFIG_KASAN_VMALLOC
+	kasan_shallow_populate_pgds(
+		kasan_mem_to_shadow((void *)PAGE_OFFSET + MAXMEM),
+		kasan_mem_to_shadow((void *)VMALLOC_END));
+
+	kasan_populate_early_shadow(
+		kasan_mem_to_shadow((void *)VMALLOC_END + 1),
+		shadow_cpu_entry_begin);
+#else
 	kasan_populate_early_shadow(
 		kasan_mem_to_shadow((void *)PAGE_OFFSET + MAXMEM),
 		shadow_cpu_entry_begin);
+#endif
=20
 	kasan_populate_shadow((unsigned long)shadow_cpu_entry_begin,
 			      (unsigned long)shadow_cpu_entry_end, 0);
--=20
2.20.1


