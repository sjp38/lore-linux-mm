Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AF0CC31E5E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:15:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DD41214AF
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:15:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DD41214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DC156B0003; Wed, 19 Jun 2019 01:15:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18B1B8E0002; Wed, 19 Jun 2019 01:15:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 053968E0001; Wed, 19 Jun 2019 01:15:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id ABF996B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 01:15:04 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m23so6839094edr.7
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 22:15:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UWpdnrbGefkQI6ssngVxJNkCRhvWsEseMpLH8MS8OO4=;
        b=rGNAX5Db5Qz3N0SV4KZhJkMUTVQ2Cy0QvAgndiqNr/KQwHaCzhliisDpFBj6eUecTA
         u6kKHDxq/MYdSj0PBN1L2rlEhPi99uKOjkIbp3N/IuiLEtNk79pmuXPPjr6jP+W4DN6A
         DTOHVDiGx871EiPklsaNcE0TV04mNcdPYFm6HDcoanvMut5E0bEmKNeGVPlUOMmMd8zg
         D836lVrVG4nhk2ECY0yD3g1d4kad6waQSh8B2M4ZcxMLUnzllnzsFju8fiucFKTnsb0A
         wyL1TopP8lx/XCmfqRQ5ZanjF87ZerOwONUd2HQ1RvvnRNrVlC0lYuBrOF+ek03gF7g0
         ISpQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVqM7tvbSqSmIXqNkGy49DtkijPHUugYdedJ31KPlSvFbEu4K2d
	C2eutAeKbrPmaRWfP00FR6Nusjge4t7529pPTTREsUBUJFiv1ESqqbRlFGHGuhQRveye+9o0xgi
	pMlPFGsJ+jvGKFkBaVvVUGswDPXf5ymGZCIi7PlQTSfpTMJEEGC1l9USWU9PcR0Q=
X-Received: by 2002:a17:906:1804:: with SMTP id v4mr2336494eje.188.1560921304196;
        Tue, 18 Jun 2019 22:15:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxziE3jD9L9/Yq2WtLjuH0JWTEOny/7v/SkFO3LFu6w9EAFoK6w6oVCsJ0S2b8GUizC68x1
X-Received: by 2002:a17:906:1804:: with SMTP id v4mr2336434eje.188.1560921303159;
        Tue, 18 Jun 2019 22:15:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560921303; cv=none;
        d=google.com; s=arc-20160816;
        b=SRzjLO5q9UAU0jw31cJaEYeFyLnakqF6DKcRFy1Uxe7VILSCW4a7T6tjUUklR4ubUm
         15jjmRZdEAMYO7IdE2Uvp/6NnjmdnBHm4Et6m9GgCmxmvlI4TCk33nqd3TLxEd0dmQKz
         vkETeVVi4oZ50MqbUpiEFESLU/yv1T0PVVVsWSuWXGEUVpO52NMODQuQQfe0UYX0Tu2r
         vJS6dos0hzFXQ3eO88bE5nFvRsdhiYVAhVYsf0leIxOVR9+xbn8KpdoZdU3qlXjzph/F
         DquMcfKW6JdbSMMBO0tMxuqFOirs9NR459UPtgUtbKJuGQQrtC/ax+SgKIao01Si37Jm
         UCvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=UWpdnrbGefkQI6ssngVxJNkCRhvWsEseMpLH8MS8OO4=;
        b=qDPDb7qtqbdTpFAvVwuB4gBRsV42k5lCZNBOa2qMIg7xjDpidpXsd9I0Tk07PWXX/q
         wxx8nFDZxJ4tigELULq0D/kqH0Ofa2HEGhC/udD3rVEqI+lg5NxpTvaxXM2PCHT2gRHZ
         5Zg4jZ4doitqOIP8OuyZ9e0S33U4FYJGCUMAE3ed50oSSpT8W2cRLUgKLO11WaQ2+Jb/
         YDpmQuTzr/Jqn/AcYafWm4LFdYRkqQsgnpT7gJ4JkE5HLImYjjRb7CkM5G5Ifl+v2aOy
         ovmG3egorPIMm6VfekGo613NV2xBMgHu3UBUe0t1h3xBFFl27gWP9LqkHu5mrrr9eb8U
         B2oQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id q55si13532093eda.257.2019.06.18.22.15.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Jun 2019 22:15:03 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id E2FD860012;
	Wed, 19 Jun 2019 05:14:58 +0000 (UTC)
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
Subject: [PATCH 5/8] mm: Start fallback top-down mmap at mm->mmap_base
Date: Wed, 19 Jun 2019 01:08:41 -0400
Message-Id: <20190619050844.5294-6-alex@ghiti.fr>
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
 mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index dedae10cb6e2..e563145c1ff4 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2185,7 +2185,7 @@ arch_get_unmapped_area_topdown(struct file *filp, unsigned long addr,
 	if (offset_in_page(addr)) {
 		VM_BUG_ON(addr != -ENOMEM);
 		info.flags = 0;
-		info.low_limit = TASK_UNMAPPED_BASE;
+		info.low_limit = arch_get_mmap_base(addr, mm->mmap_base);
 		info.high_limit = mmap_end;
 		addr = vm_unmapped_area(&info);
 	}
-- 
2.20.1

