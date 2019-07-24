Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46452C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:06:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11FCD229F3
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:06:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11FCD229F3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC18C6B0008; Wed, 24 Jul 2019 02:06:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A71EA8E0003; Wed, 24 Jul 2019 02:06:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 960998E0002; Wed, 24 Jul 2019 02:06:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 471996B0008
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:06:44 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y15so29563411edu.19
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:06:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iEUnru/pgX+pWRywt03LhpHMFzmbntBrlVCKRjubFbE=;
        b=CSDukUiRH8jd5pm+VMzNMudVbz1LCorCiFnztKw6MgSLNZ5kJ2pqxU1Ax27yqZF4Gy
         wMeXZWNIMXSxlQccdnGhvVCIFZNOMz6Du4MhxzVMDjGRRsi98OYhzqtkNMUwnpmCQKQB
         vf9KVuuY9pAsSOdp36HKcOoxbkhUZypzKpBaxl5dkx3OvshnLRGK8De9K7GjUiAeqBPG
         z4GxtuZ2PwLjHxpfIB0/tjnbSFDNP5E3wb/3erlJkBPtUbqFD7teYM5BvvlN9j4iq7SM
         M+zgLcBM8wwxsKelgIx2/rU163G1rU4gxra7Ho9jHbbthNntxdPJWx16kVjJ0hI7yETK
         ivlg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXXcQj3y+s1MTyZeDwVc0r7/YDcl0yDt4ZynnWCO//qM940xbLx
	kPpBUIOtoBA6mjgTTxEC2mYB6/OhZdB7ofihWzhLmQuGYKJaHa11GPGWG7V3aMXSVJNEraeyai9
	8pXo4P5XeBVPzHBdi175FUZkh8M/CHmwQVm8T3QNqb5vxH1QhXWsOKa7AErz7KYg=
X-Received: by 2002:a50:fa42:: with SMTP id c2mr70613489edq.48.1563948403885;
        Tue, 23 Jul 2019 23:06:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8DeulJno0snU9aOB5b/d1qjyj/gYHs6KYgkzLN9Mgf2PHC76TGkTm5MAv3VLCjyqFcewI
X-Received: by 2002:a50:fa42:: with SMTP id c2mr70613454edq.48.1563948403036;
        Tue, 23 Jul 2019 23:06:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563948403; cv=none;
        d=google.com; s=arc-20160816;
        b=wQBcNqTcSXj+Fd53VmSQ881arBBN5rbK3E81wJ9WXXZ/3SFrWAOTc3BEqHyHseewQ0
         UUECOhgJv6M2lYh5y76IQI79GAWNZLFxX7H01GL92rnTihYd51lciJjfy3EUJ8WYs+2J
         HNm+hvedWoMz9xyX9Q/bCJ8ZDxiIZI56Nx48lwSlHBIZeQPgBQ06G3OMrdJzuS+dE7Sn
         IAVKs+b9M07FAqWdimRnJeJ1VuX49TuYgXa05cGtOCjvtAON9geaIEH5idtuKNqwB7pt
         b/hEgRO9Dqp6go9eEzSC6VTJX0OUWPn4AY3J5xsOFMphHqKvOWDbGT+CZHHIHm3Fspd6
         ZWjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=iEUnru/pgX+pWRywt03LhpHMFzmbntBrlVCKRjubFbE=;
        b=IK4NdtS9ClA8mUBbnw30qU+kn9VMYmcbFBNfmQ2np/+oBsBgSbh/BU/mGyNah5mQ7B
         MaN0IsFr4mshm3yWQDL0nbW4IYZEvakZlBpZgq7P1t2qFLKT+G1DNtZ/KD2SZA0n9Xvs
         mCCswEptte/YIl0iCFgKyY+WIzCUQRqPKjUV9KiX8UyQ7S99j34+kDZ44Zpo+/wARM7a
         2WYE2/6dcV9wknjEzc5QymSZEuqw27kCVoXk57D1jOK5L4FJhCZ+Tsiq09IdKpa7kcir
         DMPfeYb/Kc6vhIOByNlLHOq+pRNwA/dK39N0mYwdasDt3zMLAlGnuZurAteOnHdbizWW
         qh0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id bq3si7216163ejb.272.2019.07.23.23.06.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Jul 2019 23:06:43 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.197;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 45F331C0007;
	Wed, 24 Jul 2019 06:06:36 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH REBASE v4 07/14] arm: Use STACK_TOP when computing mmap base address
Date: Wed, 24 Jul 2019 01:58:43 -0400
Message-Id: <20190724055850.6232-8-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190724055850.6232-1-alex@ghiti.fr>
References: <20190724055850.6232-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

mmap base address must be computed wrt stack top address, using TASK_SIZE
is wrong since STACK_TOP and TASK_SIZE are not equivalent.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Kees Cook <keescook@chromium.org>
---
 arch/arm/mm/mmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
index bff3d00bda5b..0b94b674aa91 100644
--- a/arch/arm/mm/mmap.c
+++ b/arch/arm/mm/mmap.c
@@ -19,7 +19,7 @@
 
 /* gap between mmap and stack */
 #define MIN_GAP		(128*1024*1024UL)
-#define MAX_GAP		((TASK_SIZE)/6*5)
+#define MAX_GAP		((STACK_TOP)/6*5)
 #define STACK_RND_MASK	(0x7ff >> (PAGE_SHIFT - 12))
 
 static int mmap_is_legacy(struct rlimit *rlim_stack)
@@ -51,7 +51,7 @@ static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 	else if (gap > MAX_GAP)
 		gap = MAX_GAP;
 
-	return PAGE_ALIGN(TASK_SIZE - gap - rnd);
+	return PAGE_ALIGN(STACK_TOP - gap - rnd);
 }
 
 /*
-- 
2.20.1

