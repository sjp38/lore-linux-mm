Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97AD3C433FF
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 00:17:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D4F12067D
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 00:17:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="EzjEg35m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D4F12067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F40026B0008; Wed, 14 Aug 2019 20:17:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF1CB6B000A; Wed, 14 Aug 2019 20:17:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE0DE6B000C; Wed, 14 Aug 2019 20:17:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0050.hostedemail.com [216.40.44.50])
	by kanga.kvack.org (Postfix) with ESMTP id BCAD16B0008
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:17:09 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 72D81181AC9AE
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 00:17:09 +0000 (UTC)
X-FDA: 75822747378.17.news46_2155b2fb0730c
X-HE-Tag: news46_2155b2fb0730c
X-Filterd-Recvd-Size: 6406
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com [209.85.215.195])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 00:17:08 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id e11so447576pga.5
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 17:17:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=UahEbtdXwZNAU+KwZPeJAGjgE2lYz0Dt6XczqvKwLUQ=;
        b=EzjEg35mc1bbHgqD1Ww7viar/jC2gY1ttaK6kS4nEhAVQAc9DPpjV5s9r/dHqVkDvP
         1aJjS12y4rJXR3CnBHGnF9uwmU85X95N5a/RVv5vtVMrGT/jXYcs+Npf3JRUlkGUst7Z
         Y16NXi5EAZRKf1theyPlNghDSgylNqksp2oaU=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=UahEbtdXwZNAU+KwZPeJAGjgE2lYz0Dt6XczqvKwLUQ=;
        b=VV79ubndUSUTLa0E1BTF5zVhiqHZ0EQ6pjtYqIVMYuVLjgpHJ/fQ40ZeyIx2G/ldNt
         n9eAaw2CI/+LpdoYifp2C4q+cOlg6EcxMVvm82iRnmYzd0MUKod8JBsKpNKZjz9x7kH4
         nF22BNAU6QuV/vPuwf3LslmveB1KlOkDJ2nRB5F0cPjN9359Bq+QIJbVtWHLJF4n6zxV
         WWNRa8F20UBPQ3O+r5LCmEkK5BI4yEo9RVgD6PoJHFGMhcwxdRHnC3wPd4/3BYqy5UWx
         J3bG5fhtyOmqW9ztTP2KF0T0oWTZcfcFl2RDXKI7rgQg6iDqEKEPHafYQjbJwPHrpCgx
         iFcA==
X-Gm-Message-State: APjAAAVsX+fH0Om+97eXh1lgJ0SzZWSgVl9NGvEJj7vI+H0nAqgPC6jQ
	vT823LTOw1ErIpw2UmALU9rGwHpAMAM=
X-Google-Smtp-Source: APXvYqyOwUVEeEOFMMjqi2Q7om9z/6bSJUvhnhcNlFC8BJaTT3lhedq6m2ayGeI7jcoMRi+G57aL7A==
X-Received: by 2002:aa7:9609:: with SMTP id q9mr2568209pfg.232.1565828228148;
        Wed, 14 Aug 2019 17:17:08 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id g11sm821630pgu.11.2019.08.14.17.17.06
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 14 Aug 2019 17:17:07 -0700 (PDT)
From: Daniel Axtens <dja@axtens.net>
To: kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	x86@kernel.org,
	aryabinin@virtuozzo.com,
	glider@google.com,
	luto@kernel.org,
	linux-kernel@vger.kernel.org,
	mark.rutland@arm.com,
	dvyukov@google.com
Cc: linuxppc-dev@lists.ozlabs.org,
	gor@linux.ibm.com,
	Daniel Axtens <dja@axtens.net>
Subject: [PATCH v4 3/3] x86/kasan: support KASAN_VMALLOC
Date: Thu, 15 Aug 2019 10:16:36 +1000
Message-Id: <20190815001636.12235-4-dja@axtens.net>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190815001636.12235-1-dja@axtens.net>
References: <20190815001636.12235-1-dja@axtens.net>
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

v2: move from faulting in shadow pgds to prepopulating
---
 arch/x86/Kconfig            |  1 +
 arch/x86/mm/kasan_init_64.c | 61 +++++++++++++++++++++++++++++++++++++
 2 files changed, 62 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 222855cc0158..40562cc3771f 100644
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
index 296da58f3013..2f57c4ddff61 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -245,6 +245,52 @@ static void __init kasan_map_early_shadow(pgd_t *pgd=
)
 	} while (pgd++, addr =3D next, addr !=3D end);
 }
=20
+static void __init kasan_shallow_populate_p4ds(pgd_t *pgd,
+		unsigned long addr,
+		unsigned long end,
+		int nid)
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
+
 #ifdef CONFIG_KASAN_INLINE
 static int kasan_die_handler(struct notifier_block *self,
 			     unsigned long val,
@@ -352,9 +398,24 @@ void __init kasan_init(void)
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


