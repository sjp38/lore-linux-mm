Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30DFEC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:28:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D56AB2184E
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:28:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Gqq17HZa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D56AB2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 783338E0196; Mon, 11 Feb 2019 18:28:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7334A8E0189; Mon, 11 Feb 2019 18:28:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6258A8E0196; Mon, 11 Feb 2019 18:28:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0E1BD8E0189
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:28:23 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id z4so245478wrq.1
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:28:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=ZdMEqkaTdkU9cQtnyBwyKsKlsrmvMKKieThBtq30bZY=;
        b=f4M5PJLj05mUYDkozvQT8lq3Ek06kmGC7bNRxlWHssVX+KrhpdoVoYXXfMRvuypRws
         /2QTOemP7abrJgnppJ4cZwjH8HWB/Y5XSppv/SRDe1w29BwNIHdWJ6UpvL3HZ6ivpfd3
         ZwwTLbq7cDTujIOOGMyZ3r2qyJcUHM6gMfuj05F9hf6rH3Xnshj4W3zSiCJ7uq8qsjmM
         rrR3kbHeKJK/7/Ao2HfuDDPMLTJjV+ix1K76xyauaulQsoueSZz4xNl71dK9GaHVLM4e
         yLkzofFIQmmpnW5c4PdV2GuLSJh03Px9m/ypUk6T6Uiwc9sPzkn6iM8ILL9xdNb+CHed
         Xmjg==
X-Gm-Message-State: AHQUAuY2z0zb10sB+LKIGpUOOC6lvfNUH7glfkCE4f5oMp2kn9uSLyVe
	3mN78DCygh8gAf1aBIUJIkjKMPoNcGdMRv6beqY4UcMwGERVj3AYciUsXoXrrWUZBNecp1C+WpV
	aJSd2V96HDysDt363du7hsI1mGSDfqWQdQs6y/Y4hcbfSQOxAdOyPWbRaTHagHRNvRH5Utau80/
	ALGP+Sxs2h48x3nwCVNYeVwZusIRIgWD15Iyu5jIZpV/UsPp7NjQvPuJQyUhG3LSVjw+cRgoK09
	d0PZ8j8vPpwX4nLhI2HyTi5oRzMtgLj03ixA3EtqvzMsidnOkz7kVq9OAEdjBG3cV2rYDjFTC8M
	9M5qvYOwWlR29H4dIbEJ5b0TpuX3nWinfluPfinI9PJcFgJWeamfMH2xthI0CqM9LCBFgfjlEpS
	7
X-Received: by 2002:a1c:4889:: with SMTP id v131mr479363wma.146.1549927702545;
        Mon, 11 Feb 2019 15:28:22 -0800 (PST)
X-Received: by 2002:a1c:4889:: with SMTP id v131mr479316wma.146.1549927701486;
        Mon, 11 Feb 2019 15:28:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549927701; cv=none;
        d=google.com; s=arc-20160816;
        b=zfqjJF447c0PFPRp67RiuxE+rg9YqdJri5N6a37l9HNerUxUBHRSQV8B8KErm71zS/
         tGmL7JK5GVV9a+pUpNuU5HC4QclxVprKIR3ayjF9o/TTH5W0u8njgUT1ZJ8Fd7M9IF3U
         stzgoaKjCYhrBRgLq0XPGAREd1bwepPbfJQvWoRU6gZUhb7OE0q5frw44tx5ZerOHJRI
         Mx90UOpJw7a1nenTDsuLKYm2PlmR30mYm8UoTxynlTOAsjzRh6XC5StH0NtyKbMNPQKK
         0vGh9yWvYSpudhKHDiQ4Tr//aB6KrlNb2dHSVb4+ZEZJvMO/KW17YDFAxXAZm5jD1Zn2
         o8lQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=ZdMEqkaTdkU9cQtnyBwyKsKlsrmvMKKieThBtq30bZY=;
        b=VfOUjIF9YPijWinI1SD70VKJLkW/eWNHK3LdblO88fIs8hLgcagLq5U10MrFn0u9xN
         kyIfKu6FKv5sLSNaHzNT1iTcl0K5c4sWMHmlRkMSCxILJhfuPTWMTmPPt+ucOv6AcRzM
         DYJeU2wC6UedG2xOJLQn3mkUL9j5GFNcmr1FsKVn3TSJy839lmx/J+xpVmYujqkM0lql
         huOz9BoGtYmBMz9NqFeEmBmbdOFkShEWTEc4SJJGS7Lzv18QazseCKFfs0dHjD7AaqXX
         qtrZaQTYNyKIB/CX6V9Mz9RVxNhVogFiah8ROa78HnALS00pCSdcykMaXBCB6Lg1jt//
         zXVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Gqq17HZa;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h126sor496595wmf.21.2019.02.11.15.28.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 15:28:21 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Gqq17HZa;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=ZdMEqkaTdkU9cQtnyBwyKsKlsrmvMKKieThBtq30bZY=;
        b=Gqq17HZaZ6nYNJ2Waw8C45/pT84leeq75yxS8fGSjHCrkQFeSHGV6+O/G32DVn0ZPW
         LRntTc/gWGiCzbHknpYD0WIGdPBsxF48Pi2Eqezr+FYqE5EmvTh3gCPWTYFSLfM9T3S4
         BuGCmH14QZYFnQPwRp0pjsUno0lKnQ68bBnb4VDLucg0jV9j8RZusWMJ6QcjhNcdNBeC
         Ud9mamr/FU72AoO/EsCppelcnPqu7/6ZEELqCQRUybUL7VLnarMjsDuTrtKoX/Uuclke
         S1yE7MCcTW62lyFf8XSPh0C8fTcP7AG+sX97NdgWIG8QKtRNmwZABW2W7CFA8P6s6CRg
         aDhA==
X-Google-Smtp-Source: AHgI3IaRbYzOvYY9aR2Sas9wiYW3Vep8Wn7Wc3iPNf+FO4IJVM9hmiyDf+hkZLdGHUnUWgdhWnBgeQ==
X-Received: by 2002:a1c:f916:: with SMTP id x22mr488708wmh.87.1549927701124;
        Mon, 11 Feb 2019 15:28:21 -0800 (PST)
Received: from localhost.localdomain (bba134232.alshamil.net.ae. [217.165.113.120])
        by smtp.gmail.com with ESMTPSA id e67sm1470295wmg.1.2019.02.11.15.28.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 15:28:20 -0800 (PST)
From: Igor Stoppa <igor.stoppa@gmail.com>
X-Google-Original-From: Igor Stoppa <igor.stoppa@huawei.com>
To: 
Cc: Igor Stoppa <igor.stoppa@huawei.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Nadav Amit <nadav.amit@gmail.com>,
	Matthew Wilcox <willy@infradead.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Mimi Zohar <zohar@linux.vnet.ibm.com>,
	Thiago Jung Bauermann <bauerman@linux.ibm.com>,
	Ahmed Soliman <ahmedsoliman@mena.vt.edu>,
	linux-integrity@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v4 05/12] __wr_after_init: arm64: memset_user()
Date: Tue, 12 Feb 2019 01:27:42 +0200
Message-Id: <165661e29f9a2a6aa36e51ae79a06f03b7c8718e.1549927666.git.igor.stoppa@huawei.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <cover.1549927666.git.igor.stoppa@huawei.com>
References: <cover.1549927666.git.igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

arm64 specific version of memset() for user space, memset_user()

In the __wr_after_init scenario, write-rare variables have:
- a primary read-only mapping in kernel memory space
- an alternate, writable mapping, implemented as user-space mapping

The write rare implementation expects the arch code to privide a
memset_user() function, which is currently missing.

clear_user() is the base for memset_user()

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>

CC: Andy Lutomirski <luto@amacapital.net>
CC: Nadav Amit <nadav.amit@gmail.com>
CC: Matthew Wilcox <willy@infradead.org>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Kees Cook <keescook@chromium.org>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: Mimi Zohar <zohar@linux.vnet.ibm.com>
CC: Thiago Jung Bauermann <bauerman@linux.ibm.com>
CC: Ahmed Soliman <ahmedsoliman@mena.vt.edu>
CC: linux-integrity@vger.kernel.org
CC: kernel-hardening@lists.openwall.com
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 arch/arm64/include/asm/uaccess.h   |  9 +++++
 arch/arm64/lib/Makefile            |  2 +-
 arch/arm64/lib/memset_user.S (new) | 63 ++++++++++++++++++++++++++++++++
 3 files changed, 73 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
index 547d7a0c9d05..0094f92a8f1b 100644
--- a/arch/arm64/include/asm/uaccess.h
+++ b/arch/arm64/include/asm/uaccess.h
@@ -415,6 +415,15 @@ extern unsigned long __must_check __arch_copy_in_user(void __user *to, const voi
 #define INLINE_COPY_TO_USER
 #define INLINE_COPY_FROM_USER
 
+extern unsigned long __must_check __arch_memset_user(void __user *to, int c, unsigned long n);
+static inline unsigned long __must_check __memset_user(void __user *to, int c, unsigned long n)
+{
+	if (access_ok(to, n))
+		n = __arch_memset_user(__uaccess_mask_ptr(to), c, n);
+	return n;
+}
+#define memset_user	__memset_user
+
 extern unsigned long __must_check __arch_clear_user(void __user *to, unsigned long n);
 static inline unsigned long __must_check __clear_user(void __user *to, unsigned long n)
 {
diff --git a/arch/arm64/lib/Makefile b/arch/arm64/lib/Makefile
index 5540a1638baf..614b090888de 100644
--- a/arch/arm64/lib/Makefile
+++ b/arch/arm64/lib/Makefile
@@ -1,5 +1,5 @@
 # SPDX-License-Identifier: GPL-2.0
-lib-y		:= clear_user.o delay.o copy_from_user.o		\
+lib-y		:= clear_user.o memset_user.o delay.o copy_from_user.o	\
 		   copy_to_user.o copy_in_user.o copy_page.o		\
 		   clear_page.o memchr.o memcpy.o memmove.o memset.o	\
 		   memcmp.o strcmp.o strncmp.o strlen.o strnlen.o	\
diff --git a/arch/arm64/lib/memset_user.S b/arch/arm64/lib/memset_user.S
new file mode 100644
index 000000000000..1bfbda3d112b
--- /dev/null
+++ b/arch/arm64/lib/memset_user.S
@@ -0,0 +1,63 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * memset_user.S - memset for userspace on arm64
+ *
+ * (C) Copyright 2018 Huawey Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ *
+ * Based on arch/arm64/lib/clear_user.S
+ */
+
+#include <linux/linkage.h>
+
+#include <asm/asm-uaccess.h>
+
+	.text
+
+/* Prototype: int __arch_memset_user(void *addr, int c, size_t n)
+ * Purpose  : set n bytes of user memory at "addr" to the value "c"
+ * Params   : x0 - addr, user memory address to set
+ *          : x1 - c, byte value
+ *          : x2 - n, number of bytes to set
+ * Returns  : number of bytes NOT set
+ *
+ * Alignment fixed up by hardware.
+ */
+ENTRY(__arch_memset_user)
+	uaccess_enable_not_uao x3, x4, x5
+	// replicate the byte to the whole register
+	and	x1, x1, 0xff
+	lsl	x3, x1, 8
+	orr	x1, x3, x1
+	lsl	x3, x1, 16
+	orr 	x1, x3, x1
+	lsl	x3, x1, 32
+	orr	x1, x3, x1
+	mov	x3, x2			// save the size for fixup return
+	subs	x2, x2, #8
+	b.mi	2f
+1:
+uao_user_alternative 9f, str, sttr, x1, x0, 8
+	subs	x2, x2, #8
+	b.pl	1b
+2:	adds	x2, x2, #4
+	b.mi	3f
+uao_user_alternative 9f, str, sttr, x1, x0, 4
+	sub	x2, x2, #4
+3:	adds	x2, x2, #2
+	b.mi	4f
+uao_user_alternative 9f, strh, sttrh, w1, x0, 2
+	sub	x2, x2, #2
+4:	adds	x2, x2, #1
+	b.mi	5f
+uao_user_alternative 9f, strb, sttrb, w1, x0, 0
+5:	mov	x0, #0
+	uaccess_disable_not_uao x3, x4
+	ret
+ENDPROC(__arch_memset_user)
+
+	.section .fixup,"ax"
+	.align	2
+9:	mov	x0, x3			// return the original size
+	ret
+	.previous
-- 
2.19.1

