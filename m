Return-Path: <SRS0=9bJk=RU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02731C43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 16:30:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB7BF2087F
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 16:30:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB7BF2087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58D166B02F2; Sun, 17 Mar 2019 12:30:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53A306B02F4; Sun, 17 Mar 2019 12:30:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 429E16B02F5; Sun, 17 Mar 2019 12:30:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DEC506B02F2
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 12:30:11 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o27so5934126edc.14
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 09:30:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=r/Vjiixhx3FNLOyNCupP3O6rpRbR7vCnpvYlarBDlm4=;
        b=YCxesaDQXQRAnUU6anAbGbze9BjkJzy9JgcVMEcQXNDbv8USemejYPGQyU5DWXMB7o
         Du4q2y7y3j8b8R6NVLe6K/mvJFs9wB/gF5UQKnefAHq3qNB8oB+faaHegBvZ7rxStBp2
         FBzrtlFtJ0qBPeO0eLRdjWQ0iVlK62V+B71q1p2CHtnzVSKyVkETs1I2oDWROFqwHmTh
         zrH8MOU76sSup4SbxfP1DoGw3wtu4wIVZ5PmxL+daHV3774Wco9y5TOL82kGIA4ZrZ2y
         20SJIf7w34Wn+vU/we7tZV+eQJkk6FfPPQHRc/7W1onqbkaYPzgdYoeQAawTzFG9V/AC
         4d4w==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXgbM2mDqwhS4fVV//fkVyun1LhZUNQ+tRxzdN0KhMtZ3DMo41Z
	RlOs/LE9GiCHfxXLPZoBLibaDdWRMr5HNeXTPk9jogNAcXzJfmeIvMPBgX0A0LG9kwxjQ31XYY3
	lTLeg93Vi2bN0EI52ug2sTPKEU9+fI6vOljBKJ77aoojLaNIH3MKnWEk0rkbfZ5o=
X-Received: by 2002:a17:906:2a98:: with SMTP id l24mr3833067eje.25.1552840211356;
        Sun, 17 Mar 2019 09:30:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZ8gc+/0/VVY5Yi9Vh38qvNFXmXJQdOoJAYVSW+piWFYic+S25/oXn1d2v7asFY+D6C2GJ
X-Received: by 2002:a17:906:2a98:: with SMTP id l24mr3833025eje.25.1552840210014;
        Sun, 17 Mar 2019 09:30:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552840210; cv=none;
        d=google.com; s=arc-20160816;
        b=nCpeOZK9HiTbjsjWNKWubyO30hl7To/xTfvlv7946+wX3U1nmptvt6Hx/9mI4yK8DD
         B6rV9HKJ+K/vd1KBISgxNpcYZ6X5jZeGARCuqMO4TiT68r8+GfXDf2KnJ5AmomDOH24T
         zPkmPG43OCA6CJN4cfxy9Ww7VQUJQjZJ9NJ+UF52fEcB4MBkjRsfwDuyxlfSQ5JepRUk
         jmQ/srQ0CJE6BzT5vaZ5O6qltVFNNBs1ADWPBfRt/u6xm1DeLBi/+Lw9epVA6YWtpYXi
         zE0eycpOCwkxyX2OdNUvK/TgVmU9WF8otnbdfG5z45qXMvqT/tRVUQZDvgqyRHQZtPEa
         SXMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=r/Vjiixhx3FNLOyNCupP3O6rpRbR7vCnpvYlarBDlm4=;
        b=a03DwRJr+8NFOUdIcMRJmqCHikmlLO9Z1p53DcM1VEtM5C26u4AKks0d9nnusoUA9e
         bQgLyc/mTVBK6JHVeFkDN8ZmR+swb5TqFcCCpGGYblggIFKdYLfHBDLsRBoBQtTL6cUn
         qb+l9ghwZA4Q9xcJQyJmpDMv+gRFqqsVA5EsOVix1lFVS6bffzK8TR+BHQqKVYkxtl8B
         6ZoTKUJIYCG8Dnxxh0INxitIqwl8oCzwUghAIHpkSBruaa32/TQIwHtBYD8UD7SrbkhL
         Yfd4kTGcuY7QL9w68qWAa7l2cvh/jwE+V5C86vWySDTOi3EIkUYZZ3pqKKBdFaNvp+iH
         Md4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id m10si2805557ejb.232.2019.03.17.09.30.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Mar 2019 09:30:10 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 6C5CA60005;
	Sun, 17 Mar 2019 16:30:00 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: aneesh.kumar@linux.ibm.com,
	mpe@ellerman.id.au,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
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
	Mike Kravetz <mike.kravetz@oracle.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org
Cc: Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v7 1/4] sh: Advertise gigantic page support
Date: Sun, 17 Mar 2019 12:28:44 -0400
Message-Id: <20190317162847.14107-2-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190317162847.14107-1-alex@ghiti.fr>
References: <20190317162847.14107-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

sh actually supports gigantic pages and selecting
ARCH_HAS_GIGANTIC_PAGE allows it to allocate and free
gigantic pages at runtime.

At least sdk7786_defconfig exposes such a configuration with
huge pages of 64MB, pages of 4KB and MAX_ORDER = 11:
HPAGE_SHIFT (26) - PAGE_SHIFT (12) = 14 >= MAX_ORDER (11)

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/sh/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index a9c36f95744a..299a17bed67c 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -53,6 +53,7 @@ config SUPERH
 	select HAVE_FUTEX_CMPXCHG if FUTEX
 	select HAVE_NMI
 	select NEED_SG_DMA_LENGTH
+	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
 
 	help
 	  The SuperH is a RISC processor targeted for use in embedded systems
-- 
2.20.1

