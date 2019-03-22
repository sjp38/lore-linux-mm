Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1ACBC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 14:00:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 754E4218A5
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 14:00:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="OqAGCDS8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 754E4218A5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A36306B0006; Fri, 22 Mar 2019 10:00:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A0C386B0007; Fri, 22 Mar 2019 10:00:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D4196B0008; Fri, 22 Mar 2019 10:00:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3F79F6B0007
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 10:00:09 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id x9so529984wrw.20
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 07:00:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=6pKbJUhzwfrOg+zuaOVcnvHacHuKUUR6Ss5vQGOV0qY=;
        b=OTzQw48ASdL1KayJoYH6PXBRd+aUwhsgCsoRbaUOsZJKpkh7/pv94i0pk8wirjoFmR
         HavQlGZSU5XtbGDShmVClW3QwSquYLDAiudVkvjeTbpDor03vtfFRFuBmdi2Gb4CEd6/
         GjpLbZbgSiHseWtWnin+63qMUaPxLoBIEYprnPHFg5Uv0DsYHQTJg4aN2BWI3DuptHvf
         ikRSMsxonhXg670AlZOy/+NZjNRNiKhuMTFk6+P15xIW3UNZtK9x5X2x5idhxz5BoSKX
         tgokhQkhjUlbb/8Hx52UrQmyac79XsjxE+5BPAgXG1i1IRW6X22ZZIa+nfSSB8uQcV77
         P8mQ==
X-Gm-Message-State: APjAAAWLStkiyhTuGaCTMgPgwcqCTwqrD9p6JdJ+qGXvp9K8/IMweKmG
	twbobnF9wwwGGrxZKJSlYegf+GgSqmj608jkHx5U52T4sGM2I95gmiiT8MyMUR0wRgj3xiG6OBY
	IwMPjQWxIGM/K3wjBRzLowG3gIgJc5GPz9xY5upnFEfhzJtRBryLvYSMdHBCIDYDgSA==
X-Received: by 2002:a7b:c044:: with SMTP id u4mr3364468wmc.88.1553263208690;
        Fri, 22 Mar 2019 07:00:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyf7mrSzhQR/uAostK6QvYDrVRwatagjFtZYfMzMZSENfqRA1OSnNJ7lRcWmAjh7j0d2ISd
X-Received: by 2002:a7b:c044:: with SMTP id u4mr3364405wmc.88.1553263207612;
        Fri, 22 Mar 2019 07:00:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553263207; cv=none;
        d=google.com; s=arc-20160816;
        b=rVS9CgkV3Wo3QSwkrwdo1k3WWz5rl0tGbYOIivjfpINUXFJV9VXDxxuAgPD7BRKxce
         ktPr1dTDezpf8C1ab6aMJ/N5IyyCSaW+S3j9ACpbOZmp3lXy5rpfoD5GqPfkn+red4XU
         D8G72zTR+X83SDiQqgMJ5ntXJPCdvtAYk1P2wKSsWX8fsYZwfREhX5dpRuZoy/MW2tRi
         gelD2QxcaTvMGi9ctMmpNL8hMmBgMYK32SQUGLEyrM+x8b8IxOzrRUd0FxwmjAFIi7fX
         mjtlJYMX62IgXK0Wy8Dk6UNB8bK80SqSsh+7HFEoyDSOZtjJIf6fIcLd1VO9hQJKqKF8
         gcEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=6pKbJUhzwfrOg+zuaOVcnvHacHuKUUR6Ss5vQGOV0qY=;
        b=zWSmPOZJ6LjSWQfpWscnCJ8Hg+kikvHPZW3UkffcSiyw81I1RWUB6v8UNke+nawsaz
         FNbJt/jw3AAZiT4nfJsAX0Wb/uO4jioBMsuUppjQL4Utk/kg3T+OoBjnoh3jKIN9MK3l
         RZsVmJtRM1S95zpet48GQDRiDnaJ6O//D3xH/hD1Vm3kCfu5UyZhw4GfFnowuprE5eEK
         FYY4HFDTvPSbMSQWW8kAumnrUpNYtPS0YoW8tfsJlP1rLoCMDGsBskdsH8FH6ErVSEcd
         mQXe7Qu/sEfT6CLpCrq+shWHDemgmi0N6nTJqk8CBhpmj87iU84hq8DwLMsRCRAHKNZg
         6+tw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=OqAGCDS8;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id j9si2770844wrs.321.2019.03.22.07.00.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 07:00:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=OqAGCDS8;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44QlfF4wC3z9tydZ;
	Fri, 22 Mar 2019 15:00:05 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=OqAGCDS8; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id klewezSXLrDD; Fri, 22 Mar 2019 15:00:05 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44QlfF3hFLz9tydV;
	Fri, 22 Mar 2019 15:00:05 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1553263205; bh=6pKbJUhzwfrOg+zuaOVcnvHacHuKUUR6Ss5vQGOV0qY=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=OqAGCDS8At6//wE2UY00XYmAziFxOQJEVJ9WW1SdQKvW4E8EZlSRAYu9nxM8Pw/zE
	 Phv3ky+3ndMPsQsMkIi94DQqiS5PGXfjB6+60cyjXgcVQtZ5J8NTlieYZcI4/sWxYv
	 bsei7Ywv12y/xVfh0P1q5895wfWrtJ58jqSH4njU=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id DDB448BB1E;
	Fri, 22 Mar 2019 15:00:06 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id oQ8iRHHhZNZl; Fri, 22 Mar 2019 15:00:06 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.2])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id AA9B38B848;
	Fri, 22 Mar 2019 15:00:06 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id A27676CE54; Fri, 22 Mar 2019 14:00:06 +0000 (UTC)
Message-Id: <ad694fa4179b817112e826ede8f6f1aac54746ef.1553263058.git.christophe.leroy@c-s.fr>
In-Reply-To: <45a5e13683694fc8d4574b52c4851ffb7f5e5fbd.1553263058.git.christophe.leroy@c-s.fr>
References: <45a5e13683694fc8d4574b52c4851ffb7f5e5fbd.1553263058.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [RFC PATCH v1 2/3] lib/string: move sysfs string functions out of
 string.c
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri, 22 Mar 2019 14:00:06 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In order to implement interceptors for string functions, move
higher level sysfs related string functions out of string.c

This patch creates a new file named string_sysfs.c

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 lib/Makefile       |  3 ++-
 lib/string.c       | 79 ------------------------------------------------------
 lib/string_sysfs.c | 61 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 63 insertions(+), 80 deletions(-)
 create mode 100644 lib/string_sysfs.c

diff --git a/lib/Makefile b/lib/Makefile
index 3b08673e8881..30b9b0bfbba9 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -12,12 +12,13 @@ endif
 # flaky coverage that is not a function of syscall inputs. For example,
 # rbtree can be global and individual rotations don't correlate with inputs.
 KCOV_INSTRUMENT_string.o := n
+KCOV_INSTRUMENT_string_sysfs.o := n
 KCOV_INSTRUMENT_rbtree.o := n
 KCOV_INSTRUMENT_list_debug.o := n
 KCOV_INSTRUMENT_debugobjects.o := n
 KCOV_INSTRUMENT_dynamic_debug.o := n
 
-lib-y := ctype.o string.o vsprintf.o cmdline.o \
+lib-y := ctype.o string.o string_sysfs.o vsprintf.o cmdline.o \
 	 rbtree.o radix-tree.o timerqueue.o xarray.o \
 	 idr.o int_sqrt.o extable.o \
 	 sha1.o chacha.o irq_regs.o argv_split.o \
diff --git a/lib/string.c b/lib/string.c
index 38e4ca08e757..f3886c5175ac 100644
--- a/lib/string.c
+++ b/lib/string.c
@@ -605,85 +605,6 @@ char *strsep(char **s, const char *ct)
 EXPORT_SYMBOL(strsep);
 #endif
 
-/**
- * sysfs_streq - return true if strings are equal, modulo trailing newline
- * @s1: one string
- * @s2: another string
- *
- * This routine returns true iff two strings are equal, treating both
- * NUL and newline-then-NUL as equivalent string terminations.  It's
- * geared for use with sysfs input strings, which generally terminate
- * with newlines but are compared against values without newlines.
- */
-bool sysfs_streq(const char *s1, const char *s2)
-{
-	while (*s1 && *s1 == *s2) {
-		s1++;
-		s2++;
-	}
-
-	if (*s1 == *s2)
-		return true;
-	if (!*s1 && *s2 == '\n' && !s2[1])
-		return true;
-	if (*s1 == '\n' && !s1[1] && !*s2)
-		return true;
-	return false;
-}
-EXPORT_SYMBOL(sysfs_streq);
-
-/**
- * match_string - matches given string in an array
- * @array:	array of strings
- * @n:		number of strings in the array or -1 for NULL terminated arrays
- * @string:	string to match with
- *
- * Return:
- * index of a @string in the @array if matches, or %-EINVAL otherwise.
- */
-int match_string(const char * const *array, size_t n, const char *string)
-{
-	int index;
-	const char *item;
-
-	for (index = 0; index < n; index++) {
-		item = array[index];
-		if (!item)
-			break;
-		if (!strcmp(item, string))
-			return index;
-	}
-
-	return -EINVAL;
-}
-EXPORT_SYMBOL(match_string);
-
-/**
- * __sysfs_match_string - matches given string in an array
- * @array: array of strings
- * @n: number of strings in the array or -1 for NULL terminated arrays
- * @str: string to match with
- *
- * Returns index of @str in the @array or -EINVAL, just like match_string().
- * Uses sysfs_streq instead of strcmp for matching.
- */
-int __sysfs_match_string(const char * const *array, size_t n, const char *str)
-{
-	const char *item;
-	int index;
-
-	for (index = 0; index < n; index++) {
-		item = array[index];
-		if (!item)
-			break;
-		if (sysfs_streq(item, str))
-			return index;
-	}
-
-	return -EINVAL;
-}
-EXPORT_SYMBOL(__sysfs_match_string);
-
 #ifndef __HAVE_ARCH_MEMSET
 /**
  * memset - Fill a region of memory with the given value
diff --git a/lib/string_sysfs.c b/lib/string_sysfs.c
new file mode 100644
index 000000000000..f2dd384be20d
--- /dev/null
+++ b/lib/string_sysfs.c
@@ -0,0 +1,61 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * stupid library routines for sysfs
+ *
+ */
+
+#include <linux/errno.h>
+#include <linux/export.h>
+#include <linux/string.h>
+
+/**
+ * match_string - matches given string in an array
+ * @array:	array of strings
+ * @n:		number of strings in the array or -1 for NULL terminated arrays
+ * @string:	string to match with
+ *
+ * Return:
+ * index of a @string in the @array if matches, or %-EINVAL otherwise.
+ */
+int match_string(const char * const *array, size_t n, const char *string)
+{
+	int index;
+	const char *item;
+
+	for (index = 0; index < n; index++) {
+		item = array[index];
+		if (!item)
+			break;
+		if (!strcmp(item, string))
+			return index;
+	}
+
+	return -EINVAL;
+}
+EXPORT_SYMBOL(match_string);
+
+/**
+ * __sysfs_match_string - matches given string in an array
+ * @array: array of strings
+ * @n: number of strings in the array or -1 for NULL terminated arrays
+ * @str: string to match with
+ *
+ * Returns index of @str in the @array or -EINVAL, just like match_string().
+ * Uses sysfs_streq instead of strcmp for matching.
+ */
+int __sysfs_match_string(const char * const *array, size_t n, const char *str)
+{
+	const char *item;
+	int index;
+
+	for (index = 0; index < n; index++) {
+		item = array[index];
+		if (!item)
+			break;
+		if (sysfs_streq(item, str))
+			return index;
+	}
+
+	return -EINVAL;
+}
+EXPORT_SYMBOL(__sysfs_match_string);
-- 
2.13.3

