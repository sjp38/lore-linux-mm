Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D374C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:11:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29E1C208CB
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:11:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29E1C208CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDA726B0003; Wed, 19 Jun 2019 01:11:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8A848E0002; Wed, 19 Jun 2019 01:11:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B522D8E0001; Wed, 19 Jun 2019 01:11:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B5CB6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 01:11:40 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o13so24451699edt.4
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 22:11:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=srNjincvqY5G24pyZeONdm1hP7PP/oYRsoEsOQD60iY=;
        b=Ql1euMJDp67c2PS1OiZsJzlduoCW0K7omssxOSc+k3mtZd5aJYdfxxknSRR17wlZbq
         azG8wYu7bzdU5VxsCalrn1OaB9x0E11hWpkjr3aANOmsxgYVSdU+vJbMyXKeUDoxHtY+
         PeHrETfsYDposjNAnobEuArUkn/TiweCJqVnNbRL5eehyQHDgfYlowi+FnYS4PBop+lV
         EqE7tDcGGLJKodHq1qLyfqalcEjqMrCae/XB0o4jH+TZCxDbTA/jYTx+Wb6tcOhpmahY
         xN62sHps+5aldZyU3VR09WrGqjWZ9VXVd3yFyBhrjjjtb6jvr7XIszRrMbANEcCA6/Tp
         BvGQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWD/D1bxLpR6gTWYbuz2sNJ4qlhP9khNO2M4LaKBESaWliIUIyL
	sgM6fWfwXhxMKDTP11Ajh4dcZ63q1rsm+GukxExClEWLLnZY/qDr6CgCIFEzvKZ9AAp1MXnae68
	0uN3/5wi4IWuu/M7Id+x5xKo8gtQyotdnLYQ5Pk7GqFm6Sq5n8j4nKRnZuhkZ6Kg=
X-Received: by 2002:a17:906:774e:: with SMTP id o14mr7508004ejn.175.1560921099960;
        Tue, 18 Jun 2019 22:11:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDQjR1vfstl9qAMysWC8THO91Dj79C6PZUz/QR2BGZueQRNCo7ZGPiGzRlUEBG/SAHmbk8
X-Received: by 2002:a17:906:774e:: with SMTP id o14mr7507954ejn.175.1560921098903;
        Tue, 18 Jun 2019 22:11:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560921098; cv=none;
        d=google.com; s=arc-20160816;
        b=EdU7KM20Fo7LMODTLLgwsC/zx7XjfOQWFlOMSN9Ha81kxVkUV4/CD/708tte4z6WCn
         +/npX5e4DQ33sK5E6xHZpE2iPHpwjoJbi3Ovj86/L5LGKx1l1FGCtoSzCcg4m5tnPI7v
         M7UMzJnNwc4/8HAoM8zBNg5QiFivkYPnUaIFZHESn4WHnaqTyAFTzfJFPXCYWPgPCi3T
         eyfOJBzznQKI669J0IRDwQX52BzLMJXvAjYufJHxAdrOhsxvK9Q3gsjW2x0BIU1jV9CX
         vjyVC+KnCi8NY316DE8jVlEsmNOc/d1il3n/cSY0B0LNH5I6oNT4reIb+Z/gKM9sYJsR
         r02g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=srNjincvqY5G24pyZeONdm1hP7PP/oYRsoEsOQD60iY=;
        b=ExP1VT+mXSdi62xPEZpYLF2sLFEW6iadpBhQq6c3yV8+B0RlyYqLvfGbCNWIJIavQa
         GKbFUsRa8QWBzYbIhhH0uDRc3imWUAfHV0pqcRIMPCTy3bwgi7I2k0VtP4+RekCJ9MMz
         05iggjzaW12QILeum3HNi5MjiXNMyvXUX2s/ZKJaEoPsu54J1OHZpiacRKz8/IVmuqOQ
         rz22xXzmTkPBkZOW9QZyMEancEeRdRu8N3JBv4qzmizWgHnAdXr4out44Jl5hgtEGRVs
         //Q94uyCI4i1inzm5LIKoHb/WDQTdjukjMERIUg51PG7ukYWXZKYjZrUwO96ZfYg08ep
         8teg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id h44si12885044eda.49.2019.06.18.22.11.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Jun 2019 22:11:38 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id DC9AB60010;
	Wed, 19 Jun 2019 05:11:16 +0000 (UTC)
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
Subject: [PATCH 2/8] sh: Start fallback of top-down mmap at mm->mmap_base
Date: Wed, 19 Jun 2019 01:08:38 -0400
Message-Id: <20190619050844.5294-3-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190619050844.5294-1-alex@ghiti.fr>
References: <20190619050844.5294-1-alex@ghiti.fr>
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
 arch/sh/mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/sh/mm/mmap.c b/arch/sh/mm/mmap.c
index 6a1a1297baae..4c7da92473dd 100644
--- a/arch/sh/mm/mmap.c
+++ b/arch/sh/mm/mmap.c
@@ -135,7 +135,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	if (addr & ~PAGE_MASK) {
 		VM_BUG_ON(addr != -ENOMEM);
 		info.flags = 0;
-		info.low_limit = TASK_UNMAPPED_BASE;
+		info.low_limit = mm->mmap_base;
 		info.high_limit = TASK_SIZE;
 		addr = vm_unmapped_area(&info);
 	}
-- 
2.20.1

