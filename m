Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDA48C3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 15:50:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFFBB214DA
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 15:50:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="CxO4kuP7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFFBB214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 589036B0006; Tue, 27 Aug 2019 11:50:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5393C6B0008; Tue, 27 Aug 2019 11:50:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44F806B000A; Tue, 27 Aug 2019 11:50:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0237.hostedemail.com [216.40.44.237])
	by kanga.kvack.org (Postfix) with ESMTP id 266AD6B0006
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 11:50:18 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 7BDE3482D
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 15:49:50 +0000 (UTC)
X-FDA: 75868643340.13.boot61_900e35ad6675f
X-HE-Tag: boot61_900e35ad6675f
X-Filterd-Recvd-Size: 4183
Received: from mail-qk1-f193.google.com (mail-qk1-f193.google.com [209.85.222.193])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 15:49:49 +0000 (UTC)
Received: by mail-qk1-f193.google.com with SMTP id d23so17429425qko.3
        for <linux-mm@kvack.org>; Tue, 27 Aug 2019 08:49:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=dibpdWj0PBeXuEM69FfN87DRWH5kS3v94RiPB1mv5iU=;
        b=CxO4kuP71bXMdZBURSFVdEA6wqQw9veNFs9SiOUXDz8+GLQkSMpNUvDc2+Uu7dWt5K
         2RVqK/QVIomtdFygUzu5x3xCfxHiRlG1TaWOhZw9yakOOL7eXp8igeouILW2IaBuMGay
         4KaJtN0aWzCBRsZKQ5XbWAH8QKIfmKVbVsIi6DrJvzDGlXADj65lpVVey4TVTpELbhjQ
         DAm9fF3n4JfH6dW+9Ax7obiuUAB8pkae7qQawFmQUd90wT2p/W0euy8Hh6/qYLWuMb/9
         j50hqCT+1aYw1nZRljxHT2U4ZMnPFIUFpeTnY3fVpOScRYLoiFUFUeFMkjfYEgWJnyRH
         jLaQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=dibpdWj0PBeXuEM69FfN87DRWH5kS3v94RiPB1mv5iU=;
        b=V3/mcdJRJTI8R4FIK9G29L46b/VcO1C7B8aRHszOgjY84dEg5FmRzQPk8oUKeqowc/
         pQZHdOuP8rLvp9hb7RT4QAoHbJWpiM49LFgy1PHQ79oknHvbpH7DnL8x79GNbFfYvkA3
         nAw105ueVc0p413zRncXI/rOKKyNA1UIsTB7fmbuDHUZpsUaz6dshD1jr2flyqNwkN5g
         SOXol19vgcMGyd0xZYgRRqO80BLWoe3CHxJkL4RZU/P/08D/IGwrCZ6RsE/M073ZrnZm
         2lusq4RK9qqhBoOQU3wWT2GXVUtZVZXxbuXn/2n9EqfRXly5NZ6P1tJy5y0p2b8gWuoZ
         Q/xQ==
X-Gm-Message-State: APjAAAXHAOYFaUqkzCyUQCKwHObNkfhl/2oXYWbOCkUUvM3WkaCx8c3C
	2MWknLwBZTAPhvWW/Bdov5wprg==
X-Google-Smtp-Source: APXvYqzu5/zr/pjEg/k5K28N3QPNYROqHF/i7rqJ5Ju2ChMhxp/jinXqOZrHzVQafRHebX5wnlONpg==
X-Received: by 2002:a37:c49:: with SMTP id 70mr22348368qkm.429.1566920989128;
        Tue, 27 Aug 2019 08:49:49 -0700 (PDT)
Received: from qcai.nay.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id w1sm8505153qte.36.2019.08.27.08.49.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Aug 2019 08:49:48 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: clang-built-linux@googlegroups.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] mm: silence -Woverride-init/initializer-overrides
Date: Tue, 27 Aug 2019 11:47:47 -0400
Message-Id: <1566920867-27453-1-git-send-email-cai@lca.pw>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When compiling a kernel with W=1, there are several of those warnings
due to arm64 override a field by purpose. Just disable those warnings
for both GCC and Clang of this file, so it will help dig "gems" hidden
in the W=1 warnings by reducing some noises.

mm/init-mm.c:39:2: warning: initializer overrides prior initialization
of this subobject [-Winitializer-overrides]
        INIT_MM_CONTEXT(init_mm)
        ^~~~~~~~~~~~~~~~~~~~~~~~
./arch/arm64/include/asm/mmu.h:133:9: note: expanded from macro
'INIT_MM_CONTEXT'
        .pgd = init_pg_dir,
               ^~~~~~~~~~~
mm/init-mm.c:30:10: note: previous initialization is here
        .pgd            = swapper_pg_dir,
                          ^~~~~~~~~~~~~~

Note: there is a side project trying to support explicitly allowing
specific initializer overrides in Clang, but there is no guarantee it
will happen or not.

https://github.com/ClangBuiltLinux/linux/issues/639

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/Makefile | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/Makefile b/mm/Makefile
index d0b295c3b764..5a30b8ecdc55 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -21,6 +21,9 @@ KCOV_INSTRUMENT_memcontrol.o := n
 KCOV_INSTRUMENT_mmzone.o := n
 KCOV_INSTRUMENT_vmstat.o := n
 
+CFLAGS_init-mm.o += $(call cc-disable-warning, override-init)
+CFLAGS_init-mm.o += $(call cc-disable-warning, initializer-overrides)
+
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= highmem.o memory.o mincore.o \
 			   mlock.o mmap.o mmu_gather.o mprotect.o mremap.o \
-- 
1.8.3.1


