Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB930C282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:28:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 783E1214DA
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:28:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Tt9djI+4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 783E1214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DE878E0194; Mon, 11 Feb 2019 18:28:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B6D88E0189; Mon, 11 Feb 2019 18:28:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08C038E0194; Mon, 11 Feb 2019 18:28:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id A786B8E0189
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:28:16 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id f5so238662wrt.13
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:28:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=ziJEcxmH0HELRYpJ/Cx0XBIGaICt7y2RQVCxbSTmAUA=;
        b=byrPgjpwB8PEtG1zLcWq3arkivBhBCu5urTtzfD/T6C7lSAVkWPIiWDAc+tnChtggm
         1bkCC7qcLPiOOLhDOYHy0/m+R9GOvwlz6n7SoWO+z3KG9jDY5Dhh3QvAgzrwE7D3gQ1Q
         xRSJHLLpIDEb10/wQkcMP7wxPMJRT1vHexDa6HpcWugqvmbjBPqgm6qwwWjM8eNuMOZ9
         8e8v52d7XvjVtmwF3EkYyiiCKCX3787m76M3F0yaPWrWCMMWRW1/SBeLPE3a1bplCPHi
         imlIEvMTt0p1LM8cI99dNELDWMrCe/JPqsZzj9LO5mAmXQJAZCFptkYknWoV9y2jAeil
         Z1Yg==
X-Gm-Message-State: AHQUAuacg20G0KuDEvUnRpAuoflMCxiUsoXBsyCwLXzUZIf+z3fnZNAI
	ewBM4Y7tsDhxsCLAuwWFVzTLfG67rWsvhM4cQdWG9GN8XJsbEmtbJauovzB1197SfKcfE+cMbkw
	JF5fzqanyqMM4BSd0wH2lUZw0oqNJFRwD7qRPAfWKFLbMQbFDv7ktPKZspc/0miZ+wag2gmiuHq
	dBx4yAj3ZjlYLHtUd3qLanrRBtBQVN0Klm+rZaVX5JeWO4y6o/0yqM7aSq+UhV8nillZv+X2ovW
	t39l9n+YxVWnPv3NtMKiDs05ETQPi+SrfqSyhR5UUq1cth7v/XreViWjg/tLjiTAn10IC0HLq+v
	t9j9Xk3uAv6Tux1QgisWK3j6LvY6KdWELjZulNZa9oOnIkjsdN1GJ+JIbYFaC0kYZgYM2YZlLct
	P
X-Received: by 2002:a1c:7ec4:: with SMTP id z187mr462099wmc.43.1549927696200;
        Mon, 11 Feb 2019 15:28:16 -0800 (PST)
X-Received: by 2002:a1c:7ec4:: with SMTP id z187mr462035wmc.43.1549927694940;
        Mon, 11 Feb 2019 15:28:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549927694; cv=none;
        d=google.com; s=arc-20160816;
        b=zozMLa8k5haKexxfISqKKXTMoKmqZRYt+9vI7ammM7EEgLo1ZwW6EUSd3BoxAhXqp8
         71gTbxUyejuMFguj3uRve7ma+BqNcoW2nQSkAgULqyn6hvn4noUx/eze3vN4XTetVhST
         scFV6lqwJyeLPeqW9hF+I5uq3rQ6St0zfy1bmetqXuwsOxr7oWWvXDq0SHxHwZsE7Iy6
         3zsKp897mM55wynlRIWDKZ+BGWrLjbWtxaE6KkQ+w9FtFPl1mTyhYRwNPWh+UU2qeBnI
         FLuHekO4YYWKXKe3dDpYUNsAeC2W7rTCctFYvvL+j5LCk6cCPRZ2SuoX/llMyxbbA7Yj
         55+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=ziJEcxmH0HELRYpJ/Cx0XBIGaICt7y2RQVCxbSTmAUA=;
        b=kJrycb+ku0UwT8WhqTp4jpcND4Bz/pBge0plb8fo0WIOZ8OV3ZUctjXrwonebYeZGC
         mLyDAj994obh6G224RflyXo3+1rF0nlQViGoKqmq78Ria8s3Dg2nYnJbentdJdiP+UbU
         9ZPwDq/J172qhKzWZTH3B/b5wJJYxF9e9KKDRrZ7PhJu7UtuQ27YZcwASKRZkiODcQvt
         eJM/A5wK4phdS8VK89/cACLoCBlOJmEi27jJL8/wk1UCJhqccP3ROuGc8yszMIfGRYlm
         hB71km6EwAJjkfeAcz+n+OpCrbyPh/fVXj6dODCra7aUeuP4VYaE6oPgjex/EBNiW6Tt
         6N0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Tt9djI+4;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f193sor503445wme.9.2019.02.11.15.28.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 15:28:14 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Tt9djI+4;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=ziJEcxmH0HELRYpJ/Cx0XBIGaICt7y2RQVCxbSTmAUA=;
        b=Tt9djI+4tIxxQ5z9XBIXZPNsKwfr142LlXK+hQ65M9C24x2lFzeG66B1tVAsCYEHD5
         lxkyRPZQ0d7NehS988SjU2aK0I7kZPVft7Vc+W/HY8bQPsWnifAgKghB7n90aodLDrnl
         lVPXX7q9YjeS2ulbNmlLXl6NtFYB5XvJEEgxMNocbquz7/szDVHN5yBdzXWilnSUIWV6
         5lZKYRyJD3C9KP0rHanJWixPBBH9nGwy+o8iMGvBhmhP+XMzEYm2EF0bhpt1taB4s4z5
         8y1TXoBB0V0MwKaVVuakzCSGEEpvjN4D1GunNHN9QYNv1W875CyqAi3osNxWduqQBsDv
         RurA==
X-Google-Smtp-Source: AHgI3IYd7Ah0YVUADfwQ9vu0EMe24Nxeh6S4B8+ipAqvagFO0quTn9x8ysqtHCmL+w/wBQ5gyDPMFA==
X-Received: by 2002:a1c:f50a:: with SMTP id t10mr493561wmh.126.1549927694511;
        Mon, 11 Feb 2019 15:28:14 -0800 (PST)
Received: from localhost.localdomain (bba134232.alshamil.net.ae. [217.165.113.120])
        by smtp.gmail.com with ESMTPSA id e67sm1470295wmg.1.2019.02.11.15.28.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 15:28:13 -0800 (PST)
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
Subject: [RFC PATCH v4 03/12] __wr_after_init: x86_64: randomize mapping offset
Date: Tue, 12 Feb 2019 01:27:40 +0200
Message-Id: <378ee1e7e4c17e3bf6e49e1fb6c7cd9abd18ccfe.1549927666.git.igor.stoppa@huawei.com>
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

x86_64 specialized way of defining the base address for the alternate
mapping used by write-rare.

Since the kernel address space spans across 64TB and it is mapped into a
used address space of 128TB, the kernel address space can be shifted by a
random offset that is up to 64TB and page aligned.

This is accomplished by providing arch-specific version of the function
__init_wr_base()

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
 arch/x86/mm/Makefile      |  2 ++
 arch/x86/mm/prmem.c (new) | 20 ++++++++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 4b101dd6e52f..66652de1e2c7 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -53,3 +53,5 @@ obj-$(CONFIG_PAGE_TABLE_ISOLATION)		+= pti.o
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt.o
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_identity.o
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_boot.o
+
+obj-$(CONFIG_PRMEM)		+= prmem.o
diff --git a/arch/x86/mm/prmem.c b/arch/x86/mm/prmem.c
new file mode 100644
index 000000000000..b04fc03f92fb
--- /dev/null
+++ b/arch/x86/mm/prmem.c
@@ -0,0 +1,20 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * prmem.c: Memory Protection Library - x86_64 backend
+ *
+ * (C) Copyright 2018-2019 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ */
+
+#include <linux/mm.h>
+#include <linux/mmu_context.h>
+
+unsigned long __init __init_wr_base(void)
+{
+	/*
+	 * Place 64TB of kernel address space within 128TB of user address
+	 * space, at a random page aligned offset.
+	 */
+	return (((unsigned long)kaslr_get_random_long("WR Poke")) &
+		PAGE_MASK) % (64 * _BITUL(40));
+}
-- 
2.19.1

