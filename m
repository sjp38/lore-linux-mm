Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 797EEC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29FE1222C9
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TIw6rtOy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29FE1222C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4A5F8E000C; Wed, 13 Feb 2019 17:42:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C83318E0001; Wed, 13 Feb 2019 17:42:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD0EF8E000C; Wed, 13 Feb 2019 17:42:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 58C7D8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 17:42:36 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id v16so1412489wru.8
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:42:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=wCRDB9N5TtYa3rCa6suYTZMLeDPPoUYVjqLC9Yos7dc=;
        b=cdOjLiwO7XO5HxdXXeYdPsMOM36a+2bpVHyRjFz2mq59GWbXmvU0F+mNk505zcQZXO
         RiPC2AS0DFyykP5CsWWy0RlQumh7/8xGlF+dHVr7NSbJ72LxKmks6sn8A03fdmcvsa+f
         7Q+t+ynqO2R3kAgF4mSunxTZj3UKH/faCpLNCWqOJRvXAqVe1fSswCU2hcL/GLuvAAX5
         JLoghOaWOzCwxnNWwF5FD9WBUtSsK3AsOR3AeGbMhlxvvD7sL0cAoO9UfjirwObPOiI+
         jGJhE9r625kEKMhnB3RnK2HScVyD9cC1d/NXzj81899phEy/7ctHo1Cl8WSieSK9xp9L
         7D9Q==
X-Gm-Message-State: AHQUAuaO7UcDglJ6Isx34/J5wV4QDI+e4M9vkL2CWtzvX5hOYH9rdexJ
	ibyU/zpbA98eOGm0eVhr4sOqhhBIOpNYR+w9XoDJenMVGSnlQltigazYHBuvIku93otagErpmvY
	YJiDNMGO/t3APbzZ/+0H5X8k7F+qFJs8Z+uRt8/51OjpVUj8iS6Is5lRag+DJYTFcB15OK1oZ6Y
	v+OAbBZowQpRgUmZNolbH8EKpYlGIRIZFp0kvZ/ZUhctzMhX0xVGBI0RUi46IjhA3R/5+uL7U/w
	Mw67jwjd6puw+1qKox9kxGthBgaxlpYoDXKezzRbJAj6CjUN2XI+qRqBaecMqYZ05GfzqIoJxq5
	u1CM6A8I7Af+z9p2KHttGXHHNKkVt0UVPWVSjjAtw0IQFCeNwe242AAuL2hiQ9dTR6uaL7MbOcn
	x
X-Received: by 2002:a5d:574e:: with SMTP id q14mr298614wrw.200.1550097755860;
        Wed, 13 Feb 2019 14:42:35 -0800 (PST)
X-Received: by 2002:a5d:574e:: with SMTP id q14mr298579wrw.200.1550097754523;
        Wed, 13 Feb 2019 14:42:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550097754; cv=none;
        d=google.com; s=arc-20160816;
        b=LzK6ymFHPJTr7EnEodFjXx2YhaOXP5odfqdBebzvTHeoX8+qJLxDRD506I1xOAhvQE
         PhwYY2RTazTA49trwFg7ogTytBkVNTELjAo+i7C0KhSTiRXeo0Bq6qujKCiS5kGcSg/k
         Xdp8o0rSROp+3nwRYIXcOwWgOTUhLFu9H2VwpAH2BL/1EjHl4khlR/kS7KeUfMLZoidn
         aUPS7tpomnx9BZbFjHIk2zcE5IL5u5vAFddz3ymFZE6CHhZPvpK7DmVh5Wq0gNiYjQzo
         /lh9fYCZORQV0ssJslEFOHQlrgjkrrKEuUy9u3Zb5FMqCHSuYaN0VYpWvJHu02ptBo1+
         I6Ug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=wCRDB9N5TtYa3rCa6suYTZMLeDPPoUYVjqLC9Yos7dc=;
        b=cstqDxU3KLx3qYKdD9ZEMSwEiK5kj/AD6gZgzyYE5wcKcXWckTw5amOoSewC3z4dVo
         qVHJOOosffpUhVGjPeMC10DKG6eoJ96avkfYuwvX+oaqMXbKVbBATkZDZgTL4jgOzmfj
         QlsfPZjDvuYNSZPipC+FHUyWJmcAIMMq7gKjGm2fKFikzjrYb9dsmDVxei0Z5qh2oAxF
         hAssfK82gtA367AuUHm2RNN5q4v/hFEToBd/I1jKH2S96pxFaSnGqSBBk3itj1Jgz7fm
         HdoarRT9+ZNSqSFdRjQmdc4CaiOdPy8bIPsJtrgdh+rqGK6JEl3hDpIaXlqK5ZVQxmPa
         i72g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TIw6rtOy;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y4sor397304wrh.6.2019.02.13.14.42.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 14:42:34 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TIw6rtOy;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=wCRDB9N5TtYa3rCa6suYTZMLeDPPoUYVjqLC9Yos7dc=;
        b=TIw6rtOyjaONtQsjhIlQpVLu2ZEQ+rEV+L3V2lcYZ0in1bYgfu7uBdU5k23yOKY1fu
         XU9Mxu+MU2HuBZVjPKxLOXmTqy6w5940ncoJTA0nr67mtrVOFBX5c7KM91Yn0FA0U+gb
         NkowSC0nyRckPRsIDwiUOslXXKxWKbadr043RBh+Cga1oyqFagDiS1WiT3agTR3Z3Plu
         fRTH0dNdS7wH4tCEuMF81FGEoyLIjYgzlBohqqUYqT/CNuZAGcMsdUKrgkAs2UI+h4WS
         +d4L7KdQHozJkRft3bsWZnCXq4PzN7QJ3ZozDtfNsKw6lEYxQuWxNq8TgDGfZhsGgqBp
         zF9A==
X-Google-Smtp-Source: AHgI3Ial7QSwV8vc2DB+PujK1Kt2IXsKfk76ElX0Wf6gNMPti4q1AkMfAbFdrtoGcQolDZsKqU9/qg==
X-Received: by 2002:adf:fa51:: with SMTP id y17mr292984wrr.233.1550097754132;
        Wed, 13 Feb 2019 14:42:34 -0800 (PST)
Received: from localhost.localdomain ([91.75.74.250])
        by smtp.gmail.com with ESMTPSA id f196sm780810wme.36.2019.02.13.14.42.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 14:42:33 -0800 (PST)
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
Subject: [RFC PATCH v5 11/12] __wr_after_init: test write rare functionality
Date: Thu, 14 Feb 2019 00:41:40 +0200
Message-Id: <16a099a9d40e00591b106676eb7f18cc304b1f85.1550097697.git.igor.stoppa@huawei.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <cover.1550097697.git.igor.stoppa@huawei.com>
References: <cover.1550097697.git.igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Set of test cases meant to confirm that the write rare functionality
works as expected.
It can be optionally compiled as module.

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
 mm/Kconfig.debug           |   8 +++
 mm/Makefile                |   1 +
 mm/test_write_rare.c (new) | 142 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 151 insertions(+)

diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 9a7b8b049d04..a62c31901fea 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -94,3 +94,11 @@ config DEBUG_RODATA_TEST
     depends on STRICT_KERNEL_RWX
     ---help---
       This option enables a testcase for the setting rodata read-only.
+
+config DEBUG_PRMEM_TEST
+    tristate "Run self test for statically allocated protected memory"
+    depends on PRMEM
+    default n
+    help
+      Tries to verify that the protection for statically allocated memory
+      works correctly and that the memory is effectively protected.
diff --git a/mm/Makefile b/mm/Makefile
index ef3867c16ce0..8de1d468f4e7 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -59,6 +59,7 @@ obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
 obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 obj-$(CONFIG_PRMEM) += prmem.o
+obj-$(CONFIG_DEBUG_PRMEM_TEST) += test_write_rare.o
 obj-$(CONFIG_KSM) += ksm.o
 obj-$(CONFIG_PAGE_POISONING) += page_poison.o
 obj-$(CONFIG_SLAB) += slab.o
diff --git a/mm/test_write_rare.c b/mm/test_write_rare.c
new file mode 100644
index 000000000000..e9ebc8e12041
--- /dev/null
+++ b/mm/test_write_rare.c
@@ -0,0 +1,142 @@
+// SPDX-License-Identifier: GPL-2.0
+
+/*
+ * test_write_rare.c
+ *
+ * (C) Copyright 2018 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/mm.h>
+#include <linux/bug.h>
+#include <linux/string.h>
+#include <linux/prmem.h>
+
+#ifdef pr_fmt
+#undef pr_fmt
+#endif
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+extern long __start_wr_after_init;
+extern long __end_wr_after_init;
+
+static __wr_after_init int scalar = '0';
+static __wr_after_init u8 array[PAGE_SIZE * 3] __aligned(PAGE_SIZE);
+
+/* The section must occupy a non-zero number of whole pages */
+static bool test_alignment(void)
+{
+	unsigned long pstart = (unsigned long)&__start_wr_after_init;
+	unsigned long pend = (unsigned long)&__end_wr_after_init;
+
+	if (WARN((pstart & ~PAGE_MASK) || (pend & ~PAGE_MASK) ||
+		 (pstart >= pend), "Boundaries test failed."))
+		return false;
+	pr_info("Boundaries test passed.");
+	return true;
+}
+
+static bool test_pattern(void)
+{
+	if (memchr_inv(array, '0', PAGE_SIZE / 2))
+		return pr_info("Pattern part 1 failed.");
+	if (memchr_inv(array + PAGE_SIZE / 2, '1', PAGE_SIZE * 3 / 4) )
+		return pr_info("Pattern part 2 failed.");
+	if (memchr_inv(array + PAGE_SIZE * 5 / 4, '0', PAGE_SIZE / 2))
+		return pr_info("Pattern part 3 failed.");
+	if (memchr_inv(array + PAGE_SIZE * 7 / 4, '1', PAGE_SIZE * 3 / 4))
+		return pr_info("Pattern part 4 failed.");
+	if (memchr_inv(array + PAGE_SIZE * 5 / 2, '0', PAGE_SIZE / 2))
+		return pr_info("Pattern part 5 failed.");
+	return 0;
+}
+
+static bool test_wr_memset(void)
+{
+	int new_val = '1';
+
+	wr_memset(&scalar, new_val, sizeof(scalar));
+	if (WARN(memchr_inv(&scalar, new_val, sizeof(scalar)),
+		 "Scalar write rare memset test failed."))
+		return false;
+
+	pr_info("Scalar write rare memset test passed.");
+
+	wr_memset(array, '0', PAGE_SIZE * 3);
+	if (WARN(memchr_inv(array, '0', PAGE_SIZE * 3),
+		 "Array page aligned write rare memset test failed."))
+		return false;
+
+	wr_memset(array + PAGE_SIZE / 2, '1', PAGE_SIZE * 2);
+	if (WARN(memchr_inv(array + PAGE_SIZE / 2, '1', PAGE_SIZE * 2),
+		 "Array half page aligned write rare memset test failed."))
+		return false;
+
+	wr_memset(array + PAGE_SIZE * 5 / 4, '0', PAGE_SIZE / 2);
+	if (WARN(memchr_inv(array + PAGE_SIZE * 5 / 4, '0', PAGE_SIZE / 2),
+		 "Array quarter page aligned write rare memset test failed."))
+		return false;
+
+	if (WARN(test_pattern(), "Array write rare memset test failed."))
+		return false;
+
+	pr_info("Array write rare memset test passed.");
+	return true;
+}
+
+static u8 array_1[PAGE_SIZE * 2];
+static u8 array_2[PAGE_SIZE * 2];
+
+static bool test_wr_memcpy(void)
+{
+	int new_val = 0x12345678;
+
+	wr_assign(scalar, new_val);
+	if (WARN(memcmp(&scalar, &new_val, sizeof(scalar)),
+		 "Scalar write rare memcpy test failed."))
+		return false;
+	pr_info("Scalar write rare memcpy test passed.");
+
+	wr_memset(array, '0', PAGE_SIZE * 3);
+	memset(array_1, '1', PAGE_SIZE * 2);
+	memset(array_2, '0', PAGE_SIZE * 2);
+	wr_memcpy(array + PAGE_SIZE / 2, array_1, PAGE_SIZE * 2);
+	wr_memcpy(array + PAGE_SIZE * 5 / 4, array_2, PAGE_SIZE / 2);
+
+	if (WARN(test_pattern(), "Array write rare memcpy test failed."))
+		return false;
+
+	pr_info("Array write rare memcpy test passed.");
+	return true;
+}
+
+static __wr_after_init int *dst;
+static int reference = 0x54;
+
+static bool test_wr_rcu_assign_pointer(void)
+{
+	wr_rcu_assign_pointer(dst, &reference);
+	return dst == &reference;
+}
+
+static int __init test_static_wr_init_module(void)
+{
+	pr_info("static write rare test");
+	if (WARN(!(test_alignment() &&
+		   test_wr_memset() &&
+		   test_wr_memcpy() &&
+		   test_wr_rcu_assign_pointer()),
+		 "static write rare test failed"))
+		return -EFAULT;
+	pr_info("static write rare test passed");
+	return 0;
+}
+
+module_init(test_static_wr_init_module);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Igor Stoppa <igor.stoppa@huawei.com>");
+MODULE_DESCRIPTION("Test module for static write rare.");
-- 
2.19.1

