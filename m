Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2C98C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:13:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9116E20B1F
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:13:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9116E20B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34B656B0008; Thu, 20 Jun 2019 01:13:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FB8E8E0002; Thu, 20 Jun 2019 01:13:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 175B88E0001; Thu, 20 Jun 2019 01:13:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB2206B0008
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 01:13:29 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b3so2539684edd.22
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:13:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1r8du5rzM3WoefU9HQ0cQWK6fVdukLsqJtmhoiFPfns=;
        b=ZfO/y2jF4jl0ERoZ7401Tp4IegEJoRnz7VuxXbbAlw+IsqpUL5G4eqZe6LU4prlxjO
         mTODUvep8dF9cCCo2TeNAAgbo3gphEZahdOEhiUzZBJTE44Fqj8A0TyrBpR8UesfGmPW
         dzW98z3cCUnwY+idcpX2js5Tf6cZJaRQgCR4U8dPUmPi7qY2jU4obA72Uwlrjrcy7Z0j
         H5LKMN3KCDRyP4MsNAKeyDQs7jfMkYxxmNH7aTn+tPl4OQsI/3Lf7lx3Y2vgRY+D6biU
         s2PjU3nhHomr9BCAva2pHdlTkcnxeoLaFmM9LrtDlasz7chl7AmgqmxoDRCVKFb8biOP
         SilA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXv9h6aXS7HJ3VNs+cPl/iKgC4Tcnb9GPYZhnNSytZnNMUxXhsk
	y2aV33MEZ7Roi6L6gucl5nKh1OYnfLO30fSYS8GTE0Poiao4UKovTn/H0Jz1kV9sKjq2gja1Qf5
	bU5xZ1NtlJS/5qaJOQgKSrqJ/k87oma9qpyLT4VcvrHvtGgn9g4NukF9/yu6gq2s=
X-Received: by 2002:a50:b147:: with SMTP id l7mr84833484edd.65.1561007609301;
        Wed, 19 Jun 2019 22:13:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9Zen9HBvaT9MWNSuDhD+Gr/EfdblwSunbdBBIVBibwlDDbiCzjSdJqMvruEI67OuLBY8E
X-Received: by 2002:a50:b147:: with SMTP id l7mr84833410edd.65.1561007608248;
        Wed, 19 Jun 2019 22:13:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561007608; cv=none;
        d=google.com; s=arc-20160816;
        b=gPPOGCcE5/k9Xrzx6tjOIxsXO3AwDh4DQ8jUVdrF9cYbPSB7YE2ckUw+auf0WpDDyV
         grIB7qtEwcdiidPsCJpkKnuk+m/s5QCdxA2JhK1uk4jfpiNPyazb8h5l9ytWNLaz6ZUV
         YDOSWKbPy7ne5yBAF6j7oys1MJT6sZERnGbex+BrmQfEbVMzXEtTWdF8GbEnPF6fq5ch
         rx9j+8fIU2uTUIEJn+sVITLgxiEJdjmoTWFjqH+RTro1suKAOs9bie8TeTUjvucr2Hvv
         4tgS2GLB5mlPPDAdqtViNobIcwK/nxJpTYw0rKpTU3yJJV6CN3QpwY08Pl5BJUIZY1rS
         QKTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=1r8du5rzM3WoefU9HQ0cQWK6fVdukLsqJtmhoiFPfns=;
        b=pJCoIPr82h6jlGBLcx76kKu1kY7xP6yCIZp3T16DkhByGj67jINnYgfdcZbWXaHpQv
         3C9br3jdtLbqY7pSRsG9w8J2fbssk8t8qM9aE+6ICX0Sfs3GgnTK4EqDnz19W33zP8NU
         eDlAuSAox8cSI7LTanOs8TEGBK8G0EVQa+MzPIew4RnndhTMpdQ8D7GOGG3CADPWXy1D
         H50yrMHyKEwIVyF702bUP8oW+xjHA/gvx3jGLI/x0nPPPWOZ1TBM+QyEhjbMnLUHJQHQ
         KVg7g39djR0uMZuK3Zh4vPh6O5Zwl3yr0Gqa+UNW3HJ6lnL74oJqlBKaKYEqcdpAvrOE
         81NA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay1-d.mail.gandi.net (relay1-d.mail.gandi.net. [217.70.183.193])
        by mx.google.com with ESMTPS id hk14si4163767ejb.294.2019.06.19.22.13.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Jun 2019 22:13:28 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.193;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay1-d.mail.gandi.net (Postfix) with ESMTPSA id CD96D240006;
	Thu, 20 Jun 2019 05:13:22 +0000 (UTC)
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
Subject: [PATCH RESEND 8/8] mm: Remove mmap_legacy_base and mmap_compat_legacy_code fields from mm_struct
Date: Thu, 20 Jun 2019 01:03:28 -0400
Message-Id: <20190620050328.8942-9-alex@ghiti.fr>
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

Now that x86 and parisc do not use those fields anymore, remove them from
mm code.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 include/linux/mm_types.h | 2 --
 mm/debug.c               | 4 ++--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 1d1093474c1a..9a5935f9cc7e 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -364,11 +364,9 @@ struct mm_struct {
 				unsigned long pgoff, unsigned long flags);
 #endif
 		unsigned long mmap_base;	/* base of mmap area */
-		unsigned long mmap_legacy_base;	/* base of mmap area in bottom-up allocations */
 #ifdef CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES
 		/* Base adresses for compatible mmap() */
 		unsigned long mmap_compat_base;
-		unsigned long mmap_compat_legacy_base;
 #endif
 		unsigned long task_size;	/* size of task vm space */
 		unsigned long highest_vm_end;	/* highest vma end address */
diff --git a/mm/debug.c b/mm/debug.c
index 8345bb6e4769..3ddffe1efcda 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -134,7 +134,7 @@ void dump_mm(const struct mm_struct *mm)
 #ifdef CONFIG_MMU
 		"get_unmapped_area %px\n"
 #endif
-		"mmap_base %lu mmap_legacy_base %lu highest_vm_end %lu\n"
+		"mmap_base %lu highest_vm_end %lu\n"
 		"pgd %px mm_users %d mm_count %d pgtables_bytes %lu map_count %d\n"
 		"hiwater_rss %lx hiwater_vm %lx total_vm %lx locked_vm %lx\n"
 		"pinned_vm %llx data_vm %lx exec_vm %lx stack_vm %lx\n"
@@ -162,7 +162,7 @@ void dump_mm(const struct mm_struct *mm)
 #ifdef CONFIG_MMU
 		mm->get_unmapped_area,
 #endif
-		mm->mmap_base, mm->mmap_legacy_base, mm->highest_vm_end,
+		mm->mmap_base, mm->highest_vm_end,
 		mm->pgd, atomic_read(&mm->mm_users),
 		atomic_read(&mm->mm_count),
 		mm_pgtables_bytes(mm),
-- 
2.20.1

