Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1540C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:05:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6FDCF214AF
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:05:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6FDCF214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17C856B0003; Thu, 20 Jun 2019 01:05:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 106B18E0002; Thu, 20 Jun 2019 01:05:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEA688E0001; Thu, 20 Jun 2019 01:05:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A04626B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 01:05:07 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k15so2580112eda.6
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:05:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=suPCocrA3QM64gsofO1CrTBeyBcHKAtqoGrxzUvLo4k=;
        b=B86Y7wX24/hzbysfMlj61Ty3jVAZiYhFpPNBD3EVTQbFdnFY0Ez+GPnFJrDrM7QpBH
         nX4BAuURDhlg8GTWMAC+1I5pwTQE1MOp39Nb7QdhSn7cQOhI2bYXdMukaY9SSJjrInz2
         UET5mNJpOZt1nlA75uLLL+PJDM/gzGO1+5h4c1Yh2DQRqsQZZVsduZ/jhQ64nNJs0WeC
         LXqwz3jFz0j7kOVyod/OS0MpgCh5CtkdW5onCXbqAWp3zNaDKMfRonXtmD+8z/r4xiMI
         /whVNEreHrAe2Jz76ReNwTBHG+tFPGACuroSuaMNK+cmOJyCiw/EwNhE1KkVE7kgJ1vH
         YBvA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXOLBLeOPQJ/hU6YmAb54qYFK/lvJ6gBmZksNjEzg5sMsbcs+4n
	vM6539BpJdwfcGW25ibaAImToOp0frQGmO3lcLCbfMHiohwdNjiin3T7f+qEday3+DyuwA3Nk+Z
	oHNpa0+14QBbwwNAL4n3TR5XjcAxI8vzaXIgjtM/PtDlwxuyPREQG1/9bctibEhU=
X-Received: by 2002:a50:c8c3:: with SMTP id k3mr63726375edh.189.1561007107122;
        Wed, 19 Jun 2019 22:05:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJx4KDEDLLP1NDsP996iowDXDHF1+w+XKSjB92VmG4eY85uJjtH8xl+x/sbeguhUoVoEBp
X-Received: by 2002:a50:c8c3:: with SMTP id k3mr63726299edh.189.1561007106208;
        Wed, 19 Jun 2019 22:05:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561007106; cv=none;
        d=google.com; s=arc-20160816;
        b=Xnzcb+7JsZwqvgVi2IY0k5XoUzqoQIX4C+LnZb1Tg3dZwBCvqhyuF4el1yBGPwabXr
         ihsU6b3cKpA6DPCHGeX0FW6ClrTBvTDlq7DrjoppOUR4hDmocRnF0TrK8y1aiV+3S9nI
         FprWTmJMwjtJU60bpFMCkRGCyVya2ClVZ0Xv7Z/x9LSm7Ccry+ihCcgxxjBtdm8mgQF/
         q3w2sffB8/dH05luBplP91gFvXPrwfrcTposn1dEHj3A3eHER+ET6Ko6N77102p0keCr
         i1Sspbgq6ovti1dL0yUYOEIYNDTircFnDsLsL62dRJGeYeRq2/a6l01mV4sGMrpFLcXa
         1/+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=suPCocrA3QM64gsofO1CrTBeyBcHKAtqoGrxzUvLo4k=;
        b=hzB9DynzHh4wx01jEp+rUGihAjDBYr8ZA30BreE7YXlpKYVBA76kjRn8hBA3+bF23I
         tePmQLnn1/QbEFQ9KCM8QYzmLL/IKJQpQO6I2pmp6X8064pe2s9cNZdfccCMhxMfAQrs
         WEU30d8wSylXTsUua1Acc5TF3PGF5IlewZvLt5YRmb2rnPktZW0Zst0fHLrjy13HvryF
         sebBEJgzUEjxWNii6zQZpqTXKVxxvrhxvw44eqgTpRQBjPIATaTg5Dp0iAyf/6tI5ekr
         Jyxn4x2tRW8mgWw1w2N0hfH4Kb7LE51sMHCnJOffgiAppgGMFRZI3zXOIyI2KzbAtvkb
         I3Bg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id g23si16093237eda.289.2019.06.19.22.05.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Jun 2019 22:05:06 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id DA6C6FF804;
	Thu, 20 Jun 2019 05:04:55 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>,
	Helge Deller <deller@gmx.de>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S . Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H . Peter Anvin" <hpa@zytor.com>,
	x86@kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	linux-parisc@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH RESEND 1/8] s390: Start fallback of top-down mmap at mm->mmap_base
Date: Thu, 20 Jun 2019 01:03:21 -0400
Message-Id: <20190620050328.8942-2-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190620050328.8942-1-alex@ghiti.fr>
References: <20190620050328.8942-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In case of mmap failure in top-down mode, there is no need to go through
the whole address space again for the bottom-up fallback: the goal of this
fallback is to find, as a last resort, space between the top-down mmap base
and the stack, which is the only place not covered by the top-down mmap.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/s390/mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/s390/mm/mmap.c b/arch/s390/mm/mmap.c
index cbc718ba6d78..4a222969843b 100644
--- a/arch/s390/mm/mmap.c
+++ b/arch/s390/mm/mmap.c
@@ -166,7 +166,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	if (addr & ~PAGE_MASK) {
 		VM_BUG_ON(addr != -ENOMEM);
 		info.flags = 0;
-		info.low_limit = TASK_UNMAPPED_BASE;
+		info.low_limit = mm->mmap_base;
 		info.high_limit = TASK_SIZE;
 		addr = vm_unmapped_area(&info);
 		if (addr & ~PAGE_MASK)
-- 
2.20.1

