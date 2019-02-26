Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08D16C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:22:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D8F721848
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:22:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="pQr0TLBQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D8F721848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 103748E0006; Tue, 26 Feb 2019 12:22:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 068858E0007; Tue, 26 Feb 2019 12:22:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D5D478E0006; Tue, 26 Feb 2019 12:22:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5BDA88E0003
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:22:47 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id m7so6588150wrn.15
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:22:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=0QUiUDKjGToLpkzDPACzHo0JlotDF22Jf4TM6PGaWLw=;
        b=At488zhd2+JWRPjkQ0V3nPY8h16wqTbrr/6IZ751FYZOrxJdkfD/eCj3w8H6iRUsfr
         o7REu1p1IfGx2D52yv6dz5CkR0aGpEVkoZs9xeickGil924uH/vQeeNljwGrCMKr/6Vg
         DyBKRAlHin/2BzqVjp9Owf+quuaxSnUeRv39/vKFUqZHyxFQA9zWCzF25k52wfh8ysLV
         k2nVuWMpQpv3qYNeYuscUaZyFJ+sVozM6uXlwQ953AADvTg8lg0/1CGgOPGyqrbustqE
         GdrQLQon+4weDyMFONIhXCEbJBHlxoMxreMnpwKXP9Od8InWEkGL/xzLkBwsFGSmMdu4
         m4nA==
X-Gm-Message-State: AHQUAua6Xap1fixvSajFKScxu9X6WJ8dBq5IiQUqnmZWHr/sSMpmQEk5
	eCPQzR4Ox1a/SjCuEBulvTb3dT2NKONLGDNWD+aA6snCVh2etSsOXyrC3Cre65mhnILCyFR7X5E
	nUazs4CazM6ySG228ao1oQMyoWir9ydQ3okBpEYPobB8yEem9OiXpfv/H04dd69TxeQ==
X-Received: by 2002:a5d:4f91:: with SMTP id d17mr18708725wru.67.1551201766807;
        Tue, 26 Feb 2019 09:22:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib4Zw+kZJSEkxa4rGIW14WM9ju4mAuK1c73zJhTgkG+MNZ5Sj3pMrlMykM1P66FSbl8Infy
X-Received: by 2002:a5d:4f91:: with SMTP id d17mr18708653wru.67.1551201765386;
        Tue, 26 Feb 2019 09:22:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551201765; cv=none;
        d=google.com; s=arc-20160816;
        b=OXs/zqA+Ylx191VXzgclUbXPzjWXkEpEemYbD4MDsBmrJobGp8RID8FUladHq5lMLz
         9JKlcYypUhScj8fO8sTdNIx/7df30jDrf3hvYzfi306Amzdo3cmX7YvIt3hEXwe7KWwc
         r7JWkWZa9/7af4WkrWEvUfKz3/SCj4Mullxw0wz5aV20XGSBEmWoa55NxOlZe8aFBU4V
         oPCz4VQaHtcyE4NnEJ8Sz0RUTlzelABQCSZP2lYMaWxSaS18EUtzOO8W058esv7HzpV4
         0ifI79pxHY3cE1YU8D1bcemU77G6Vqr2nwjvhBuJqTBv9hNHSr1rwwg1QuFLaveobaZp
         SbVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=0QUiUDKjGToLpkzDPACzHo0JlotDF22Jf4TM6PGaWLw=;
        b=AEI6jgmQSSCSPtGBYlUkiFU/drYab4c26Jxc6m7aXwMMrfbP1aGj+mwhx4f064h/5H
         mKF/sHL1RfAzmhiG0hK9sValOsQImLpt5pTZCt2R2t8nkTk5qWq3K3N5gOhLfwtsmbO2
         yLQ3rodyndY/ZVmm7Q0JAYt04k9LEAeRy0Ne5xlBCwxDiQaOJ6ls56Wp1sox1S9+0bJs
         hxbJLQwSKqyxFWBToh8g6yNTtdXWGawP+fVzDcysy3r8x04HEI42Dgh/zQCPmDzxMemF
         cf9ETH6d6FJV3g2qPzIknQD5R3aB+tGsqn5JfNHHCBUyh05RKvRfN/DKEyc9Pchc86TA
         HMjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=pQr0TLBQ;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id l10si7358407wme.68.2019.02.26.09.22.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 09:22:45 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=pQr0TLBQ;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 4485H72RvJz9vJLd;
	Tue, 26 Feb 2019 18:22:43 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=pQr0TLBQ; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id PZf4mHXeE6w4; Tue, 26 Feb 2019 18:22:43 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 4485H71K1jz9vJLY;
	Tue, 26 Feb 2019 18:22:43 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551201763; bh=0QUiUDKjGToLpkzDPACzHo0JlotDF22Jf4TM6PGaWLw=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=pQr0TLBQ4eR9EuTvoAjTc41AKQMmEBcjz8cdsYomIQWiRTdvvB8YjbXRBIGRGH+cJ
	 L0s2Oz0252mphg9sII3J5E77eUAWALpUBuQaefDcnwcawKBTeFExwMNz4lOesMuTwn
	 A8EGRLAsH8CK97xYRRqRWJ5aEVmurpToztVAB6Mc=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id CE2708B97A;
	Tue, 26 Feb 2019 18:22:44 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id F2qHldtmh0UV; Tue, 26 Feb 2019 18:22:44 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 6EBEE8B96A;
	Tue, 26 Feb 2019 18:22:44 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 470A86F7B5; Tue, 26 Feb 2019 17:22:44 +0000 (UTC)
Message-Id: <3dc2d1c23a3fe65dc99f9e3b82fb34c151e13d33.1551161392.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551161392.git.christophe.leroy@c-s.fr>
References: <cover.1551161392.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v8 03/11] powerpc/prom_init: don't use string functions from
 lib/
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 26 Feb 2019 17:22:44 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When KASAN is active, the string functions in lib/ are doing the
KASAN checks. This is too early for prom_init.

This patch implements dedicated string functions for prom_init,
which will be compiled in with KASAN disabled.

Size of prom_init before the patch:
   text	   data	    bss	    dec	    hex	filename
  12060	    488	   6960	  19508	   4c34	arch/powerpc/kernel/prom_init.o

Size of prom_init after the patch:
   text	   data	    bss	    dec	    hex	filename
  12460	    488	   6960	  19908	   4dc4	arch/powerpc/kernel/prom_init.o

This increases the size of prom_init a bit, but as prom_init is
in __init section, it is freed after boot anyway.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/prom_init.c        | 213 ++++++++++++++++++++++++++-------
 arch/powerpc/kernel/prom_init_check.sh |   2 +-
 2 files changed, 173 insertions(+), 42 deletions(-)

diff --git a/arch/powerpc/kernel/prom_init.c b/arch/powerpc/kernel/prom_init.c
index f33ff4163a51..56d5639ab082 100644
--- a/arch/powerpc/kernel/prom_init.c
+++ b/arch/powerpc/kernel/prom_init.c
@@ -224,6 +224,137 @@ static bool  __prombss rtas_has_query_cpu_stopped;
 #define PHANDLE_VALID(p)	((p) != 0 && (p) != PROM_ERROR)
 #define IHANDLE_VALID(i)	((i) != 0 && (i) != PROM_ERROR)
 
+/* Copied from lib/string.c and lib/kstrtox.c */
+
+static int __init prom_strcmp(const char *cs, const char *ct)
+{
+	unsigned char c1, c2;
+
+	while (1) {
+		c1 = *cs++;
+		c2 = *ct++;
+		if (c1 != c2)
+			return c1 < c2 ? -1 : 1;
+		if (!c1)
+			break;
+	}
+	return 0;
+}
+
+static char __init *prom_strcpy(char *dest, const char *src)
+{
+	char *tmp = dest;
+
+	while ((*dest++ = *src++) != '\0')
+		/* nothing */;
+	return tmp;
+}
+
+static int __init prom_strncmp(const char *cs, const char *ct, size_t count)
+{
+	unsigned char c1, c2;
+
+	while (count) {
+		c1 = *cs++;
+		c2 = *ct++;
+		if (c1 != c2)
+			return c1 < c2 ? -1 : 1;
+		if (!c1)
+			break;
+		count--;
+	}
+	return 0;
+}
+
+static size_t __init prom_strlen(const char *s)
+{
+	const char *sc;
+
+	for (sc = s; *sc != '\0'; ++sc)
+		/* nothing */;
+	return sc - s;
+}
+
+static int __init prom_memcmp(const void *cs, const void *ct, size_t count)
+{
+	const unsigned char *su1, *su2;
+	int res = 0;
+
+	for (su1 = cs, su2 = ct; 0 < count; ++su1, ++su2, count--)
+		if ((res = *su1 - *su2) != 0)
+			break;
+	return res;
+}
+
+static char __init *prom_strstr(const char *s1, const char *s2)
+{
+	size_t l1, l2;
+
+	l2 = prom_strlen(s2);
+	if (!l2)
+		return (char *)s1;
+	l1 = prom_strlen(s1);
+	while (l1 >= l2) {
+		l1--;
+		if (!prom_memcmp(s1, s2, l2))
+			return (char *)s1;
+		s1++;
+	}
+	return NULL;
+}
+
+#ifdef CONFIG_CMDLINE
+static size_t __init prom_strlcpy(char *dest, const char *src, size_t size)
+{
+	size_t ret = prom_strlen(src);
+
+	if (size) {
+		size_t len = (ret >= size) ? size - 1 : ret;
+		memcpy(dest, src, len);
+		dest[len] = '\0';
+	}
+	return ret;
+}
+#endif
+
+#ifdef CONFIG_PPC_PSERIES
+static int __init prom_strtobool(const char *s, bool *res)
+{
+	if (!s)
+		return -EINVAL;
+
+	switch (s[0]) {
+	case 'y':
+	case 'Y':
+	case '1':
+		*res = true;
+		return 0;
+	case 'n':
+	case 'N':
+	case '0':
+		*res = false;
+		return 0;
+	case 'o':
+	case 'O':
+		switch (s[1]) {
+		case 'n':
+		case 'N':
+			*res = true;
+			return 0;
+		case 'f':
+		case 'F':
+			*res = false;
+			return 0;
+		default:
+			break;
+		}
+	default:
+		break;
+	}
+
+	return -EINVAL;
+}
+#endif
 
 /* This is the one and *ONLY* place where we actually call open
  * firmware.
@@ -555,7 +686,7 @@ static int __init prom_setprop(phandle node, const char *nodename,
 	add_string(&p, tohex((u32)(unsigned long) value));
 	add_string(&p, tohex(valuelen));
 	add_string(&p, tohex(ADDR(pname)));
-	add_string(&p, tohex(strlen(pname)));
+	add_string(&p, tohex(prom_strlen(pname)));
 	add_string(&p, "property");
 	*p = 0;
 	return call_prom("interpret", 1, 1, (u32)(unsigned long) cmd);
@@ -639,25 +770,25 @@ static void __init early_cmdline_parse(void)
 		l = prom_getprop(prom.chosen, "bootargs", p, COMMAND_LINE_SIZE-1);
 #ifdef CONFIG_CMDLINE
 	if (l <= 0 || p[0] == '\0') /* dbl check */
-		strlcpy(prom_cmd_line,
+		prom_strlcpy(prom_cmd_line,
 			CONFIG_CMDLINE, sizeof(prom_cmd_line));
 #endif /* CONFIG_CMDLINE */
 	prom_printf("command line: %s\n", prom_cmd_line);
 
 #ifdef CONFIG_PPC64
-	opt = strstr(prom_cmd_line, "iommu=");
+	opt = prom_strstr(prom_cmd_line, "iommu=");
 	if (opt) {
 		prom_printf("iommu opt is: %s\n", opt);
 		opt += 6;
 		while (*opt && *opt == ' ')
 			opt++;
-		if (!strncmp(opt, "off", 3))
+		if (!prom_strncmp(opt, "off", 3))
 			prom_iommu_off = 1;
-		else if (!strncmp(opt, "force", 5))
+		else if (!prom_strncmp(opt, "force", 5))
 			prom_iommu_force_on = 1;
 	}
 #endif
-	opt = strstr(prom_cmd_line, "mem=");
+	opt = prom_strstr(prom_cmd_line, "mem=");
 	if (opt) {
 		opt += 4;
 		prom_memory_limit = prom_memparse(opt, (const char **)&opt);
@@ -669,13 +800,13 @@ static void __init early_cmdline_parse(void)
 
 #ifdef CONFIG_PPC_PSERIES
 	prom_radix_disable = !IS_ENABLED(CONFIG_PPC_RADIX_MMU_DEFAULT);
-	opt = strstr(prom_cmd_line, "disable_radix");
+	opt = prom_strstr(prom_cmd_line, "disable_radix");
 	if (opt) {
 		opt += 13;
 		if (*opt && *opt == '=') {
 			bool val;
 
-			if (kstrtobool(++opt, &val))
+			if (prom_strtobool(++opt, &val))
 				prom_radix_disable = false;
 			else
 				prom_radix_disable = val;
@@ -1028,7 +1159,7 @@ static int __init prom_count_smt_threads(void)
 		type[0] = 0;
 		prom_getprop(node, "device_type", type, sizeof(type));
 
-		if (strcmp(type, "cpu"))
+		if (prom_strcmp(type, "cpu"))
 			continue;
 		/*
 		 * There is an entry for each smt thread, each entry being
@@ -1475,7 +1606,7 @@ static void __init prom_init_mem(void)
 			 */
 			prom_getprop(node, "name", type, sizeof(type));
 		}
-		if (strcmp(type, "memory"))
+		if (prom_strcmp(type, "memory"))
 			continue;
 
 		plen = prom_getprop(node, "reg", regbuf, sizeof(regbuf));
@@ -1756,19 +1887,19 @@ static void __init prom_initialize_tce_table(void)
 		prom_getprop(node, "device_type", type, sizeof(type));
 		prom_getprop(node, "model", model, sizeof(model));
 
-		if ((type[0] == 0) || (strstr(type, "pci") == NULL))
+		if ((type[0] == 0) || (prom_strstr(type, "pci") == NULL))
 			continue;
 
 		/* Keep the old logic intact to avoid regression. */
 		if (compatible[0] != 0) {
-			if ((strstr(compatible, "python") == NULL) &&
-			    (strstr(compatible, "Speedwagon") == NULL) &&
-			    (strstr(compatible, "Winnipeg") == NULL))
+			if ((prom_strstr(compatible, "python") == NULL) &&
+			    (prom_strstr(compatible, "Speedwagon") == NULL) &&
+			    (prom_strstr(compatible, "Winnipeg") == NULL))
 				continue;
 		} else if (model[0] != 0) {
-			if ((strstr(model, "ython") == NULL) &&
-			    (strstr(model, "peedwagon") == NULL) &&
-			    (strstr(model, "innipeg") == NULL))
+			if ((prom_strstr(model, "ython") == NULL) &&
+			    (prom_strstr(model, "peedwagon") == NULL) &&
+			    (prom_strstr(model, "innipeg") == NULL))
 				continue;
 		}
 
@@ -1917,12 +2048,12 @@ static void __init prom_hold_cpus(void)
 
 		type[0] = 0;
 		prom_getprop(node, "device_type", type, sizeof(type));
-		if (strcmp(type, "cpu") != 0)
+		if (prom_strcmp(type, "cpu") != 0)
 			continue;
 
 		/* Skip non-configured cpus. */
 		if (prom_getprop(node, "status", type, sizeof(type)) > 0)
-			if (strcmp(type, "okay") != 0)
+			if (prom_strcmp(type, "okay") != 0)
 				continue;
 
 		reg = cpu_to_be32(-1); /* make sparse happy */
@@ -1998,9 +2129,9 @@ static void __init prom_find_mmu(void)
 		return;
 	version[sizeof(version) - 1] = 0;
 	/* XXX might need to add other versions here */
-	if (strcmp(version, "Open Firmware, 1.0.5") == 0)
+	if (prom_strcmp(version, "Open Firmware, 1.0.5") == 0)
 		of_workarounds = OF_WA_CLAIM;
-	else if (strncmp(version, "FirmWorks,3.", 12) == 0) {
+	else if (prom_strncmp(version, "FirmWorks,3.", 12) == 0) {
 		of_workarounds = OF_WA_CLAIM | OF_WA_LONGTRAIL;
 		call_prom("interpret", 1, 1, "dev /memory 0 to allow-reclaim");
 	} else
@@ -2033,7 +2164,7 @@ static void __init prom_init_stdout(void)
 	call_prom("instance-to-path", 3, 1, prom.stdout, path, 255);
 	prom_printf("OF stdout device is: %s\n", of_stdout_device);
 	prom_setprop(prom.chosen, "/chosen", "linux,stdout-path",
-		     path, strlen(path) + 1);
+		     path, prom_strlen(path) + 1);
 
 	/* instance-to-package fails on PA-Semi */
 	stdout_node = call_prom("instance-to-package", 1, 1, prom.stdout);
@@ -2043,7 +2174,7 @@ static void __init prom_init_stdout(void)
 		/* If it's a display, note it */
 		memset(type, 0, sizeof(type));
 		prom_getprop(stdout_node, "device_type", type, sizeof(type));
-		if (strcmp(type, "display") == 0)
+		if (prom_strcmp(type, "display") == 0)
 			prom_setprop(stdout_node, path, "linux,boot-display", NULL, 0);
 	}
 }
@@ -2064,19 +2195,19 @@ static int __init prom_find_machine_type(void)
 		compat[len] = 0;
 		while (i < len) {
 			char *p = &compat[i];
-			int sl = strlen(p);
+			int sl = prom_strlen(p);
 			if (sl == 0)
 				break;
-			if (strstr(p, "Power Macintosh") ||
-			    strstr(p, "MacRISC"))
+			if (prom_strstr(p, "Power Macintosh") ||
+			    prom_strstr(p, "MacRISC"))
 				return PLATFORM_POWERMAC;
 #ifdef CONFIG_PPC64
 			/* We must make sure we don't detect the IBM Cell
 			 * blades as pSeries due to some firmware issues,
 			 * so we do it here.
 			 */
-			if (strstr(p, "IBM,CBEA") ||
-			    strstr(p, "IBM,CPBW-1.0"))
+			if (prom_strstr(p, "IBM,CBEA") ||
+			    prom_strstr(p, "IBM,CPBW-1.0"))
 				return PLATFORM_GENERIC;
 #endif /* CONFIG_PPC64 */
 			i += sl + 1;
@@ -2093,7 +2224,7 @@ static int __init prom_find_machine_type(void)
 			   compat, sizeof(compat)-1);
 	if (len <= 0)
 		return PLATFORM_GENERIC;
-	if (strcmp(compat, "chrp"))
+	if (prom_strcmp(compat, "chrp"))
 		return PLATFORM_GENERIC;
 
 	/* Default to pSeries. We need to know if we are running LPAR */
@@ -2155,7 +2286,7 @@ static void __init prom_check_displays(void)
 	for (node = 0; prom_next_node(&node); ) {
 		memset(type, 0, sizeof(type));
 		prom_getprop(node, "device_type", type, sizeof(type));
-		if (strcmp(type, "display") != 0)
+		if (prom_strcmp(type, "display") != 0)
 			continue;
 
 		/* It seems OF doesn't null-terminate the path :-( */
@@ -2259,9 +2390,9 @@ static unsigned long __init dt_find_string(char *str)
 	s = os = (char *)dt_string_start;
 	s += 4;
 	while (s <  (char *)dt_string_end) {
-		if (strcmp(s, str) == 0)
+		if (prom_strcmp(s, str) == 0)
 			return s - os;
-		s += strlen(s) + 1;
+		s += prom_strlen(s) + 1;
 	}
 	return 0;
 }
@@ -2294,7 +2425,7 @@ static void __init scan_dt_build_strings(phandle node,
 		}
 
  		/* skip "name" */
- 		if (strcmp(namep, "name") == 0) {
+		if (prom_strcmp(namep, "name") == 0) {
  			*mem_start = (unsigned long)namep;
  			prev_name = "name";
  			continue;
@@ -2306,7 +2437,7 @@ static void __init scan_dt_build_strings(phandle node,
 			namep = sstart + soff;
 		} else {
 			/* Trim off some if we can */
-			*mem_start = (unsigned long)namep + strlen(namep) + 1;
+			*mem_start = (unsigned long)namep + prom_strlen(namep) + 1;
 			dt_string_end = *mem_start;
 		}
 		prev_name = namep;
@@ -2375,7 +2506,7 @@ static void __init scan_dt_build_struct(phandle node, unsigned long *mem_start,
 			break;
 
  		/* skip "name" */
- 		if (strcmp(pname, "name") == 0) {
+		if (prom_strcmp(pname, "name") == 0) {
  			prev_name = "name";
  			continue;
  		}
@@ -2406,7 +2537,7 @@ static void __init scan_dt_build_struct(phandle node, unsigned long *mem_start,
 		call_prom("getprop", 4, 1, node, pname, valp, l);
 		*mem_start = _ALIGN(*mem_start, 4);
 
-		if (!strcmp(pname, "phandle"))
+		if (!prom_strcmp(pname, "phandle"))
 			has_phandle = 1;
 	}
 
@@ -2476,8 +2607,8 @@ static void __init flatten_device_tree(void)
 
 	/* Add "phandle" in there, we'll need it */
 	namep = make_room(&mem_start, &mem_end, 16, 1);
-	strcpy(namep, "phandle");
-	mem_start = (unsigned long)namep + strlen(namep) + 1;
+	prom_strcpy(namep, "phandle");
+	mem_start = (unsigned long)namep + prom_strlen(namep) + 1;
 
 	/* Build string array */
 	prom_printf("Building dt strings...\n"); 
@@ -2799,7 +2930,7 @@ static void __init fixup_device_tree_efika(void)
 	rv = prom_getprop(node, "model", prop, sizeof(prop));
 	if (rv == PROM_ERROR)
 		return;
-	if (strcmp(prop, "EFIKA5K2"))
+	if (prom_strcmp(prop, "EFIKA5K2"))
 		return;
 
 	prom_printf("Applying EFIKA device tree fixups\n");
@@ -2807,13 +2938,13 @@ static void __init fixup_device_tree_efika(void)
 	/* Claiming to be 'chrp' is death */
 	node = call_prom("finddevice", 1, 1, ADDR("/"));
 	rv = prom_getprop(node, "device_type", prop, sizeof(prop));
-	if (rv != PROM_ERROR && (strcmp(prop, "chrp") == 0))
+	if (rv != PROM_ERROR && (prom_strcmp(prop, "chrp") == 0))
 		prom_setprop(node, "/", "device_type", "efika", sizeof("efika"));
 
 	/* CODEGEN,description is exposed in /proc/cpuinfo so
 	   fix that too */
 	rv = prom_getprop(node, "CODEGEN,description", prop, sizeof(prop));
-	if (rv != PROM_ERROR && (strstr(prop, "CHRP")))
+	if (rv != PROM_ERROR && (prom_strstr(prop, "CHRP")))
 		prom_setprop(node, "/", "CODEGEN,description",
 			     "Efika 5200B PowerPC System",
 			     sizeof("Efika 5200B PowerPC System"));
diff --git a/arch/powerpc/kernel/prom_init_check.sh b/arch/powerpc/kernel/prom_init_check.sh
index 181fd10008ef..4cac45cb5de5 100644
--- a/arch/powerpc/kernel/prom_init_check.sh
+++ b/arch/powerpc/kernel/prom_init_check.sh
@@ -27,7 +27,7 @@ fi
 WHITELIST="add_reloc_offset __bss_start __bss_stop copy_and_flush
 _end enter_prom $MEM_FUNCS reloc_offset __secondary_hold
 __secondary_hold_acknowledge __secondary_hold_spinloop __start
-strcmp strcpy strlcpy strlen strncmp strstr kstrtobool logo_linux_clut224
+logo_linux_clut224
 reloc_got2 kernstart_addr memstart_addr linux_banner _stext
 __prom_init_toc_start __prom_init_toc_end btext_setup_display TOC."
 
-- 
2.13.3

