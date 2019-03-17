Return-Path: <SRS0=9bJk=RU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD6A6C43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 16:29:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 657562087C
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 16:29:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 657562087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C926D6B02F1; Sun, 17 Mar 2019 12:29:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C66846B02F2; Sun, 17 Mar 2019 12:29:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B556D6B02F3; Sun, 17 Mar 2019 12:29:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9186B02F1
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 12:29:02 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x21so5569545edr.17
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 09:29:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=xCNRn2CIAnTHo9UxBJEx7xAGfNa9hKnwX3RpbP1l3F0=;
        b=Zf6L9ecfSZyfa04LiAqCJ53VkNcD/ogwA7sji2o7xpWvqsJ/UMHCwDPzgzjXQEenhN
         szeJ6Wu2Baq1BZmgFZLTH0bQDlTPpAuSj+pBwGuedl0TFJiMnZzbPi09nETBX4A0Ac+W
         9EJ82/WMZ3QcV4hKZEZRGM2jU9Bh34J6txXmRTBcNrAQTf/RP84MkROTGJVU3XrdEWC3
         5NP9e46kUnDbbdODz4sqf+HSx13F4epS1FgEtLMuFZgCOIlLmECQtZA6uB16sCmHE7fR
         CsXEbS5Jxj1HbeD8yCsVpiCC6xQ7WKpiJHJBnA6dOnIUzinUFK3wppG5sFtrjqhC4T5g
         s6ZQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXkVP1KWNoibL9JRjFSzQq4CNiMW88oALAZN6/UF0MJGGbVKkGH
	safvrCJE3dbpuklasDnhyAjFoUghmiGcW+OsiJYF0wXi6SgBvobsex/L6gBZDZltFq8tdo6+KTk
	K2pjj4zMa6YbmMvTnSZWWyq6tLJOumdDxOfk+f3zqL/s7vYC0JEDDvmSE5+Cvc34=
X-Received: by 2002:a50:b673:: with SMTP id c48mr9654267ede.138.1552840141817;
        Sun, 17 Mar 2019 09:29:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgMc7A+1yslKIWyEXS9S60uh3rNycN/LqURoTIDrJolbdvRTeucmLwCNnuchtKlZ2o18+A
X-Received: by 2002:a50:b673:: with SMTP id c48mr9654208ede.138.1552840140471;
        Sun, 17 Mar 2019 09:29:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552840140; cv=none;
        d=google.com; s=arc-20160816;
        b=LkB09G3JvblpGJXeM0sEyW9Tulw0n6Ms7OveDXC3qZiJ1CBYiuCWqFIm4fOa2v0bbH
         KY6/UeuOa/sVBc6+yCpqYS4w6Rdv7LFC3zitUSICJ7CnsY8cVz2bg3CL0JYPQ1DjUYAV
         pB88YDz4pqZEkF3QNfA1+sFSpbzju75LnD+3//joHjkI6O1R306b0jPaxrPhdVhysHTr
         JW6CrWSPdlhKxayKNPn0RhjUV06ykt49A5nRLagf8LXYVNIipa5uZPeKgkuALBC0zvWc
         yX1QSRZkhicPlLtVtrRPoLvUZCtFNNRuqX6HET8KZ55/hH1bFNIyUjdb/Wvcyxpd4c/2
         3B9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=xCNRn2CIAnTHo9UxBJEx7xAGfNa9hKnwX3RpbP1l3F0=;
        b=gr4ddRwCPIg5pMZb7XO8BP4km3wwBybCRv3o6JSVe8AbJ0rlCeaLW9ygldWq3qD8iU
         VqkNNuLqdwiObDeyTBXnOuc5wiHufSh4+V6VndMEbrJqtulWCrRaxSyCHFARgaGc5cao
         Q0pd/2mF8LcTGANbFPnTTqZxz9aTIx7eBODMuxJJZxpsEz1TnSbUHRfA7mwiGM5lkOUf
         LFgKc4MZxyGrf8/xJ7RBPFObL3rhBE/KFUivTO4zf7BClQKHeHlaP5WaOC9t9/H9ggov
         i2UlBNnauemF536hZ/LDg0m7f6t4UJwmikreOsOWLy4ziyDAmXCSC0HEjefrl8BCmb/p
         znJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id i14si2005351ejy.50.2019.03.17.09.29.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Mar 2019 09:29:00 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.197;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 811461C0004;
	Sun, 17 Mar 2019 16:28:50 +0000 (UTC)
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
Subject: [PATCH v7 0/4] Fix free/allocation of runtime gigantic pages
Date: Sun, 17 Mar 2019 12:28:43 -0400
Message-Id: <20190317162847.14107-1-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

his series fixes sh and sparc that did not advertise their gigantic page
support and then were not able to allocate and free those pages at runtime.
It renames MEMORY_ISOLATION && COMPACTION || CMA condition into the more
accurate CONTIG_ALLOC, since it allows the definition of alloc_contig_range
function.
Finally, it then fixes the wrong definition of ARCH_HAS_GIGANTIC_PAGE config
that, without MEMORY_ISOLATION && COMPACTION || CMA defined, did not allow
architectures to free boottime allocated gigantic pages although unrelated.

Changes in v7:
  I thought gigantic page support was settled at compile time, but Aneesh
  and Michael have just come up with a patch proving me wrong for
  powerpc: https://patchwork.ozlabs.org/patch/1047003/. So this version:
  - reintroduces gigantic_page_supported renamed into
    gigantic_page_runtime_supported
  - reintroduces gigantic page page support corresponding checks (not
    everywhere though: set_max_huge_pages check was redundant with
    __nr_hugepages_store_common)
  - introduces the possibility for arch to override this function
    by using asm-generic/hugetlb.h current semantics although Aneesh
    proposed something else.

Changes in v6:
- Remove unnecessary goto since the fallthrough path does the same and is
  the 'normal' behaviour, as suggested by Dave Hensen
- Be more explicit in comment in set_max_huge_page: we return an error
  if alloc_contig_range is not defined and the user tries to allocate a
  gigantic page (we keep the same behaviour as before this patch), but we
  now let her free boottime gigantic page, as suggested by Dave Hensen
- Add Acked-by, thanks. 

Changes in v5:
- Fix bug in previous version thanks to Mike Kravetz
- Fix block comments that did not respect coding style thanks to Dave Hensen
- Define ARCH_HAS_GIGANTIC_PAGE only for sparc64 as advised by David Miller
- Factorize "def_bool" and "depends on" thanks to Vlastimil Babka

Changes in v4 as suggested by Dave Hensen:
- Split previous version into small patches
- Do not compile alloc_gigantic** functions for architectures that do not
  support those pages
- Define correct ARCH_HAS_GIGANTIC_PAGE in all arch that support them to avoid
  useless runtime check
- Add comment in set_max_huge_pages to explain that freeing is possible even
  without CONTIG_ALLOC defined
- Remove gigantic_page_supported function across all archs

Changes in v3 as suggested by Vlastimil Babka and Dave Hansen:
- config definition was wrong and is now in mm/Kconfig
- COMPACTION_CORE was renamed in CONTIG_ALLOC

Changes in v2 as suggested by Vlastimil Babka:
- Get rid of ARCH_HAS_GIGANTIC_PAGE
- Get rid of architecture specific gigantic_page_supported
- Factorize CMA or (MEMORY_ISOLATION && COMPACTION) into COMPACTION_CORE 

Alexandre Ghiti (4):
  sh: Advertise gigantic page support
  sparc: Advertise gigantic page support
  mm: Simplify MEMORY_ISOLATION && COMPACTION || CMA into CONTIG_ALLOC
  hugetlb: allow to free gigantic pages regardless of the configuration

 arch/arm64/Kconfig                           |  2 +-
 arch/arm64/include/asm/hugetlb.h             |  4 --
 arch/powerpc/include/asm/book3s/64/hugetlb.h |  7 ---
 arch/powerpc/platforms/Kconfig.cputype       |  2 +-
 arch/s390/Kconfig                            |  2 +-
 arch/s390/include/asm/hugetlb.h              |  3 --
 arch/sh/Kconfig                              |  1 +
 arch/sparc/Kconfig                           |  1 +
 arch/x86/Kconfig                             |  2 +-
 arch/x86/include/asm/hugetlb.h               |  4 --
 arch/x86/mm/hugetlbpage.c                    |  2 +-
 include/asm-generic/hugetlb.h                | 14 +++++
 include/linux/gfp.h                          |  4 +-
 mm/Kconfig                                   |  3 ++
 mm/hugetlb.c                                 | 54 ++++++++++++++------
 mm/page_alloc.c                              |  7 ++-
 16 files changed, 67 insertions(+), 45 deletions(-)

-- 
2.20.1

