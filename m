Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99689C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 19:41:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 470C02067D
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 19:41:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="gVnr52O9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 470C02067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBC946B0007; Fri,  2 Aug 2019 15:41:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6DA36B0008; Fri,  2 Aug 2019 15:41:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C82656B000A; Fri,  2 Aug 2019 15:41:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A736D6B0007
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 15:41:40 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id x1so65488397qkn.6
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 12:41:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=WQAwxez96oUqOKhi5Otfo6AhSFIujCjLEKW9DkJRHyE=;
        b=QpDmXFeqIDuBlepOZndpexmNrmgVCw+sqY0VUmACvqATdjYNgzzDr5p8SsBW8Zj/XU
         C5KIQo01ZOZUkxCuBU3t6L5pZkUtNeD8Ac7N3cdIIdocimQLlDb64Pt7iQaLQ9Kny7Nq
         U46C0xCFnPpw1at/HizMsdGkCwCBtxl75Pg3t3SJ8KvwBDtFV32NBlUkgreEwRtzXxSO
         z2wjI7eyyz8y0d0v/yAU6u9Rzn/JcFhyV4DP55FlT/gNS3SDRbyy4cbIaR67Tye0W5L7
         kBA34wdspifj854PKZuvliE10LiDyxLyX+dAHF5xboY3IvO46Eh0DOwXo/x3gBC4f7Gf
         g6FQ==
X-Gm-Message-State: APjAAAXgP5HNVwBpDeCjHZPcfqjDl6vKOWzu0NtYgE9NJLs+4Nn9N3AH
	6CSIZ2T32Qbz4hAHS0R1USWSci34p83gAmNODVoC2G6Jz4eqH9xgNFM6tAMSCzcytn5+y56FepP
	y2pc0TMExyUZWXeilzKUCbNK3anHKzMKucCjQ9fJdqFAk0zpuZ2J6Ira1FuUtzdlzBA==
X-Received: by 2002:a37:9a8b:: with SMTP id c133mr84471341qke.261.1564774900411;
        Fri, 02 Aug 2019 12:41:40 -0700 (PDT)
X-Received: by 2002:a37:9a8b:: with SMTP id c133mr84471314qke.261.1564774899798;
        Fri, 02 Aug 2019 12:41:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564774899; cv=none;
        d=google.com; s=arc-20160816;
        b=GfXYPPkz6KAsKd0Y281DFVRtZhtHk6uDvsdosnib7tMDN8SiF5TbNTXhJWRBmmOtF9
         ZDqiTdjYrEyTXnSIsHGuhwRuAkBVtZl9Mj+Br2JgR8sXNTDd8IKNBPlEqj+87k4JIkPE
         DgFe1+EUge/YsQC4r2SW//VDh8YtfW6sLr4N+4rAWh8WW5ruKzLhBPTS3I7uGFdpfh1Z
         j1Hv5Ld4UBBcY/zodIneoznUjMfEf0IWlSlVgnn6uwkxEESUvZdc5fTSAPJDwrU57o/3
         +JmQUgHbIY5wiAz9rBcLMjjMYMTS3eq1kaBhZUHRdJekwfI8GRTMHQ+K/BMNiaPpdFch
         hiLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=WQAwxez96oUqOKhi5Otfo6AhSFIujCjLEKW9DkJRHyE=;
        b=Air28ysBke+nDXN0hTNQRcKQXhYYsR7HsWiuZLH6IFCXysx9TV5zYOX3K0ikO6Mu6s
         qKCKyh6j5su5CTYIyQadchrfhe84T/YiQe4j/RvbFXMJPED5YDFJJiYhDyGTJjLwWtQR
         C4IyjvaTWY/tBTVI6zbi/iRxpjq6s0Q1lJOF6qfHWVZXEFYyG3AcpZrrkdvLdoM51M+z
         uSJy93c0cuxUsV+iVwOX2zqOzQdr6P3LY5KKWNmcLYx8aTUwxNCHFjDnTM0q3b1NA/0q
         uDIZgIYFXbs9iixzgWWyIo6qqXfqV8HhxDEGm8yPLSWujYYRYW9QfKYfNKksxSIkMARi
         PSRw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=gVnr52O9;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j6sor43883255qke.111.2019.08.02.12.41.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Aug 2019 12:41:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=gVnr52O9;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=WQAwxez96oUqOKhi5Otfo6AhSFIujCjLEKW9DkJRHyE=;
        b=gVnr52O9krwfQO7y4J7MjYdcZqCTJpMMIUn+Z08zsYXXmEldYmkrxz0coPApUy1ns/
         yAK8FI9kIlFe4gSaS3flfVCu+64pNIpWD8Nr6B9mGDiOGd4T+YruwYAE26ld3JoQYHSB
         WZlQQRQQ5yeCgDnStPHP5ReCPMMrnIx+7Qqs07vRfgEaTCfGaiOPC1jMRWP7/1sTRDL0
         FqWzYJT5bVZmot8Q9K9s8csJZvJE4DU2LHyqq2ddCmefRM0ilTCRJtCJw4bC3AycPHGP
         itefR9moAo171YUlBbl5L1+wChREPsXT4S9LhMGO1fbN5/LdsHuzVoT1iRp7wOD9pYOQ
         TBIg==
X-Google-Smtp-Source: APXvYqynXU2mckBK2mwl5pSKz+zstWguPmWFjVj13oC2WPpCvJ7NZTmDSEt0zerfIF1SxvJdKDtbMA==
X-Received: by 2002:a37:48c7:: with SMTP id v190mr93631953qka.350.1564774899382;
        Fri, 02 Aug 2019 12:41:39 -0700 (PDT)
Received: from qcai.nay.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id 39sm41877782qts.41.2019.08.02.12.41.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 12:41:38 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: arnd@arndb.de,
	kirill.shutemov@linux.intel.com,
	mhocko@suse.com,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] asm-generic: fix variable 'p4d' set but not used
Date: Fri,  2 Aug 2019 15:41:22 -0400
Message-Id: <1564774882-22926-1-git-send-email-cai@lca.pw>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

GCC throws a warning on an arm64 system since the commit 9849a5697d3d
("arch, mm: convert all architectures to use 5level-fixup.h"),

mm/kasan/init.c: In function 'kasan_free_p4d':
mm/kasan/init.c:344:9: warning: variable 'p4d' set but not used
[-Wunused-but-set-variable]
  p4d_t *p4d;
         ^~~

because p4d_none() in "5level-fixup.h" is compiled away while it is a
static inline function in "pgtable-nopud.h". However, if converted
p4d_none() to a static inline there, powerpc would be unhappy as it
reads those in assembler language in
"arch/powerpc/include/asm/book3s/64/pgtable.h",

./include/asm-generic/5level-fixup.h: Assembler messages:
./include/asm-generic/5level-fixup.h:20: Error: unrecognized opcode:
`static'
./include/asm-generic/5level-fixup.h:21: Error: junk at end of line,
first unrecognized character is `{'
./include/asm-generic/5level-fixup.h:22: Error: unrecognized opcode:
`return'
./include/asm-generic/5level-fixup.h:23: Error: junk at end of line,
first unrecognized character is `}'
./include/asm-generic/5level-fixup.h:25: Error: unrecognized opcode:
`static'
./include/asm-generic/5level-fixup.h:26: Error: junk at end of line,
first unrecognized character is `{'
./include/asm-generic/5level-fixup.h:27: Error: unrecognized opcode:
`return'
./include/asm-generic/5level-fixup.h:28: Error: junk at end of line,
first unrecognized character is `}'
./include/asm-generic/5level-fixup.h:30: Error: unrecognized opcode:
`static'
./include/asm-generic/5level-fixup.h:31: Error: junk at end of line,
first unrecognized character is `{'
./include/asm-generic/5level-fixup.h:32: Error: unrecognized opcode:
`return'
./include/asm-generic/5level-fixup.h:33: Error: junk at end of line,
first unrecognized character is `}'
make[2]: *** [scripts/Makefile.build:375:
arch/powerpc/kvm/book3s_hv_rmhandlers.o] Error 1

Fix it by reference the variable in the macro instead.

Signed-off-by: Qian Cai <cai@lca.pw>
---
 include/asm-generic/5level-fixup.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/asm-generic/5level-fixup.h b/include/asm-generic/5level-fixup.h
index bb6cb347018c..2c3e14c924b6 100644
--- a/include/asm-generic/5level-fixup.h
+++ b/include/asm-generic/5level-fixup.h
@@ -19,7 +19,7 @@
 
 #define p4d_alloc(mm, pgd, address)	(pgd)
 #define p4d_offset(pgd, start)		(pgd)
-#define p4d_none(p4d)			0
+#define p4d_none(p4d)			((void)p4d, 0)
 #define p4d_bad(p4d)			0
 #define p4d_present(p4d)		1
 #define p4d_ERROR(p4d)			do { } while (0)
-- 
1.8.3.1

