Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7A3BC10F00
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A44D5222C9
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AT0rnd8B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A44D5222C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 41A988E0005; Wed, 13 Feb 2019 17:42:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3CB1E8E0001; Wed, 13 Feb 2019 17:42:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 292008E0005; Wed, 13 Feb 2019 17:42:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id C35968E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 17:42:11 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id f4so1448686wrg.9
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:42:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=ziJEcxmH0HELRYpJ/Cx0XBIGaICt7y2RQVCxbSTmAUA=;
        b=WyLkXaRPNnXb7MxCwCwqHq5/DwYd42nFEG+yYpEcnwgt5ThT6VxQ+9Vl0/CkTMGdGi
         khC2gmQXqLxCDUzariIy8FXPIaDt97gr7VwUblJy7Xmp536F+7p5WNSUyr+C2h8WNsM4
         FVB4OCcC2fHap+oqilB5ybcYbJRVlXXicocamf4EYRfpqz45VPvDPCYk6Uxx+8RdD29i
         p6Ex9DnqRUQIfKHIoWj1N8HO6stw4jolprpHMmDCI8aseLwef9aY2HJTBDyS758WGQV3
         MGwTaK0e19LOOjnYOG83yE4TyJvV81/2AucsuzOLHBT2/2wgObbS2A3AfvPEuysc3s/H
         l2MQ==
X-Gm-Message-State: AHQUAua+ch34gU0KE6lpEDr9aMr6Jj/e269SA0tbPAqhDE8DqffQHD0t
	R8FZeWXxhbzaTjW9OBracmYi75Hp0udLrqKpgELp98hpWZSvf6GK4JU3Um1bX9adcKY8txE4ZDy
	Yboa87p7tfcUhNaAZq0/7XK2OX//GJDeJ7L4slY23xCI3LcgiX9FIzVsQ1ozCDXRRVEr/e28mLH
	pC6qXtWM/33LfdoDHGpvEZgxki+E9ZrNsfl/aipbTC5OyS7VxsO68sxgCo2YddHW77w2nVkAVdy
	jpBi348li/ZAI6ECK/e7I/AoU9BIKY5wFCCIp4wn8xLpIUBCs0rFO/kDbWaQf/8ha/YStncs/bS
	UOW290IWqyjUW3JVDIUpbpmBRZYqae++KQtooGzORfBRHaaThlFm9/oQaqjgkzdAVpb+XIw5In6
	j
X-Received: by 2002:a1c:7ec4:: with SMTP id z187mr270566wmc.43.1550097731321;
        Wed, 13 Feb 2019 14:42:11 -0800 (PST)
X-Received: by 2002:a1c:7ec4:: with SMTP id z187mr270522wmc.43.1550097730035;
        Wed, 13 Feb 2019 14:42:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550097730; cv=none;
        d=google.com; s=arc-20160816;
        b=BfBiruVrDw/zpTL/pos5BatqESbH+edNjQ8WhHEXZcYciZU+UiKPLFUMpAYt22Udy3
         dai6R4NLzxN4iRvYQ6DAgu3kF07RbIiRf5ucZvK/MPMJpm2jDwB6fygPPwz5rD3fVUbb
         2MkHUaQ1DBCIqlI1K8ZOaRvEl8NzbBVjEbsP94l28svhUU37WmO7Kbz5u951RHDByBNI
         9BG60UMv/IFkNNHtyojkMyICpEHZTC9SBGAABqitK5VJrC9oGK6oBHJ40N9LypkzTQq4
         0H/GXwc+V4DoGNMgvtJ7+y7bH7/qQS2qsGTGaobwUfmf6CVGGM/8vyXYW5uUExW0W6B6
         DXyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=ziJEcxmH0HELRYpJ/Cx0XBIGaICt7y2RQVCxbSTmAUA=;
        b=zVhDCJVHsJ6H+4B0b0XS0bcqaGfgcQ0pTyc2Wha1F/5wt+y5pLdcntHyKCS9bFCDT+
         mg6ipOCPFm8QYIdNs+qJhc6DpPTyYou1mAcc0AQLL8ft3iXBP4+wOEH/dmX7b4h4ulBW
         LBJnJPNfpQ+gOOHekTpc5BWiSdaHN83iD5o/5cL2p6NwHtJt7ZSmTsgxOOEd2j8WCIYN
         UvdC4APnw0H3586hze4e9D26a2qVqDmM7jE+lqhD4AUUUoE05Wk2kBcZxlARIj2ItPI7
         9q3glTa1YRRHNdtIRq48eAYersBwMPszK8mQc0TjLOvIn/tMNcx9pfaeMFDA6FgncQPp
         gwrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AT0rnd8B;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n12sor394671wrm.10.2019.02.13.14.42.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 14:42:10 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AT0rnd8B;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=ziJEcxmH0HELRYpJ/Cx0XBIGaICt7y2RQVCxbSTmAUA=;
        b=AT0rnd8BnDyFyzfZmtZcyeTBEWOmVhTvPmEu5QNum22iV2TcKjKPwLVNWNeagC0CRy
         ctLWeeTYC/+F6/tKvEGXpJEyq+9Yz6bCFYiyBbA3twYThdmj5oAWC32/BvKKUsEGEX7o
         Ld9HklU7c97NPh13SsZ6fCE/5BMVPh9dqK1naXMrYOstuBxbrBxG+SqHXwEloEStPyvR
         ffmv8EeqFFFoGyKtg14GqIYxFVbRpPQFp2z+rCCaXp+qC/Cyh9Zji9wP1jG6KdtLhlYx
         p7hNzJkTQdZOgNlQY/A8FTBEwkpMfs3AiT9jAGZANXbmBbnzIfgztEwbiLzC+FwV2x8J
         VLpg==
X-Google-Smtp-Source: AHgI3IYtU8/AyDQPgRNLGyOtrkGvf7ehC6WRZeZ6D8zc6PNd3G4s/XlOJrLl2q5Ckle3r/z/jdGkyg==
X-Received: by 2002:adf:fa0d:: with SMTP id m13mr285795wrr.93.1550097729690;
        Wed, 13 Feb 2019 14:42:09 -0800 (PST)
Received: from localhost.localdomain ([91.75.74.250])
        by smtp.gmail.com with ESMTPSA id f196sm780810wme.36.2019.02.13.14.42.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 14:42:09 -0800 (PST)
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
Subject: [RFC PATCH v5 04/12] __wr_after_init: x86_64: randomize mapping offset
Date: Thu, 14 Feb 2019 00:41:33 +0200
Message-Id: <4f3b363bfd20ec0d79a0b066581d72145bb65883.1550097697.git.igor.stoppa@huawei.com>
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

