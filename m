Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8143C10F00
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75C90222C9
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HV9aVsJP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75C90222C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2B538E0002; Wed, 13 Feb 2019 17:41:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDC658E0001; Wed, 13 Feb 2019 17:41:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC9FF8E0002; Wed, 13 Feb 2019 17:41:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 76E4D8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 17:41:59 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id v16so1411891wru.8
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:41:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:reply-to:mime-version:content-transfer-encoding;
        bh=v//UVpOdI2pMBj7QngoAd2+0IKN5JRjyVZ7fMRhNP+M=;
        b=rZUDORxKddtnjPWrnC4lyp5GNPlZ00hbUDEjpX+kHRos+BHzj0oC3X6LNz6w/JNOQ6
         e09MQ++vLg9QdvOeW8ureFBKx312ArNzGLVU0n+KIPtFr0F+Orp8FC1+mvcdyhGEbF0k
         iB0o14jk3gdbdjczoqERmNXQOW+LsIyyPYcx9pshh16RCW9lQXKv8lEHfsoLbvj0HaFT
         FSIuev/rwGP8kZyCbCXp55lJhHfSPsvBcvaxrkF1gZwA+Cwza5OffnxLbMu465ELVZQj
         8tLLuv/Wh2NHgXhIXGp6FyckL+ET+YDa72ZBhmVHRk4zmzKOGUhcPyH30LLyHaDrAvzI
         hGEg==
X-Gm-Message-State: AHQUAube+v7mol5Ip8+ot+jg4HHKwIJPO55LTcV5PFWosYHEFr4ay/Ni
	T6LK7MGfCF8JuQ74EwfMzSch5ZLSgi/zVYWwuLRGEruoOK+KPMAFRQFJqXMznwkLgNJRUYvGUTT
	3HxQtdhJZ4oFBfTew2h1f3Dx7CWS1nEEvM0mfI46MayvvJs252UOyjuBVUX5OyE2+Lnvs/1Dudr
	yEAgDAb+xTo3n2Ufs32f9h/GCt/bAS5bRfbvKOFN3Yfh0+wNZhpe7DY6y0PNSLhNQUyRBU1XAPa
	8cTpRmSW2E1ljbL64GUxoqoou9gxj9VF58bpicF/UeQfIzxs1GSSGr4UoAq1enmAdKY94sBMYgb
	6BIpM/hp7x6bX5BjDygg+p8pMl3gc/RjiPgjt5dpvm+dLYvrezZUpymQikIzwTs/iA6mRhOGn99
	f
X-Received: by 2002:a5d:6b46:: with SMTP id x6mr269295wrw.305.1550097718563;
        Wed, 13 Feb 2019 14:41:58 -0800 (PST)
X-Received: by 2002:a5d:6b46:: with SMTP id x6mr269263wrw.305.1550097717422;
        Wed, 13 Feb 2019 14:41:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550097717; cv=none;
        d=google.com; s=arc-20160816;
        b=CaSjlaGKcemLTbGebyg6oS3pPkIco125o8cf3HEK+94Sj6SKcjAxhkJjTA5gr0bUTL
         FCIYoDc1UbSFT527No+nJVGJTBBGGbBwX1tntRnm3FUsG4dtroQjnfkFpcfdMq/SNY+1
         TIQdo/pN5yp5WZvDFLGmiJp68fnE7SDHAQYlLSlw9OTQCkgvClFj24xjlxKx89JNqx0K
         z6VFmjRJIEUZU3TYIpI6UPT+YUCfOjeIuwe1ifxX9Eqe2oen6eu9YAxcENsFbgrDYoAj
         jAXEJyYznmnwaZV3pTyNPvhICW8CKMYYWUwKrPd2IVdX3bDtk7yki21ruQCSEtZkthlJ
         n/MQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=v//UVpOdI2pMBj7QngoAd2+0IKN5JRjyVZ7fMRhNP+M=;
        b=MkmS/e29UFm2Y8gcdg35VWv/7czMozatrPZqySv84DS/XeZ8caBZncGzqwfJ95zgN5
         PJNWGhvAbuzki2vctc9dY97Ojx/oLTRSs+LjNgyDHzwTdEd3pBbZFBU750kZXsyM5+zC
         rEhN9armq3iN2myHa6I21KDn9wQM9tWc/izKw80H8VFPz2FU30WjwVWI3kPhgGhNYkXt
         v/sNpUr5S5G1kuUK8aJpeuhzge6Nt1y5cXJLBY573Wy+Gl34xqEhEl+GpU+kuGBvTj4G
         D7RwIEKPrMxNa17jUzODRvye9/d2tY1Z+5f/gtV3n82EgcV1vbVkm6VRVlzyaEyLazGQ
         v9CA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HV9aVsJP;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y13sor361649wru.50.2019.02.13.14.41.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 14:41:57 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HV9aVsJP;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:reply-to:mime-version
         :content-transfer-encoding;
        bh=v//UVpOdI2pMBj7QngoAd2+0IKN5JRjyVZ7fMRhNP+M=;
        b=HV9aVsJPiTJ8ZtGFtYNGVlu+kroKUKT0z0DZv7bbng1WJtW39lNBcvRrJ4L2yi8thp
         8GgJBfqo5LY41MIA4JzsvzB9JICICqzCxkxwMgRnIohIkBLovLdHs8zA2bXaV0ivk8dE
         T5/W2cyc4qGmNas/ftPIQ1eIB2CJHuajsm3wvGcs9ZNK4DOzLweatVfsI30+HGbJYInb
         JgoK4tB/kYtLHG+NI2Vp5v5mXStjmL1hP1Eg+MF/OKVcGOVRy9Cru/ptSYzI3HKWAFAR
         Z7biHK7zLf7raY13IZ4KLoAdgkY3w1C8KDgVpPi8eSWOoZe83PcX7qUn8cQFVzefOy9/
         29cw==
X-Google-Smtp-Source: AHgI3IZUuVHIWSI5hYTH0/oiUtwLakqcG7yQVPGl6sKahQzdaJJLWVEUPmv7QWzr17ryUO0e9iB5YQ==
X-Received: by 2002:adf:b60e:: with SMTP id f14mr296526wre.134.1550097716715;
        Wed, 13 Feb 2019 14:41:56 -0800 (PST)
Received: from localhost.localdomain ([91.75.74.250])
        by smtp.gmail.com with ESMTPSA id f196sm780810wme.36.2019.02.13.14.41.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 14:41:55 -0800 (PST)
From: Igor Stoppa <igor.stoppa@gmail.com>
X-Google-Original-From: Igor Stoppa <igor.stoppa@huawei.com>
To: 
Cc: Igor Stoppa <igor.stoppa@huawei.com>,
	Kees Cook <keescook@chromium.org>,
	Ahmed Soliman <ahmedsoliman@mena.vt.edu>,
	linux-integrity <linux-integrity@vger.kernel.org>,
	Kernel Hardening <kernel-hardening@lists.openwall.com>,
	Linux-MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: [RFC PATCH v5 00/12] hardening: statically allocated protected memory
Date: Thu, 14 Feb 2019 00:41:29 +0200
Message-Id: <cover.1550097697.git.igor.stoppa@huawei.com>
X-Mailer: git-send-email 2.19.1
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

To: Andy Lutomirski <luto@amacapital.net>,
To: Matthew Wilcox <willy@infradead.org>,
To: Nadav Amit <nadav.amit@gmail.com>
To: Peter Zijlstra <peterz@infradead.org>,
To: Dave Hansen <dave.hansen@linux.intel.com>,
To: Mimi Zohar <zohar@linux.vnet.ibm.com>
To: Thiago Jung Bauermann <bauerman@linux.ibm.com>
CC: Kees Cook <keescook@chromium.org>
CC: Ahmed Soliman <ahmedsoliman@mena.vt.edu>
CC: linux-integrity <linux-integrity@vger.kernel.org>
CC: Kernel Hardening <kernel-hardening@lists.openwall.com>
CC: Linux-MM <linux-mm@kvack.org>
CC: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hello,
new version of the patchset, with default memset_user() function.

Patch-set implementing write-rare memory protection for statically
allocated data.
Its purpose is to keep write protected the kernel data which is seldom
modified, especially if altering it can be exploited during an attack.

There is no read overhead, however writing requires special operations that
are probably unsuitable for often-changing data.
The use is opt-in, by applying the modifier __wr_after_init to a variable
declaration.

As the name implies, the write protection kicks in only after init() is
completed; before that moment, the data is modifiable in the usual way.

Current Limitations:
* supports only data which is allocated statically, at build time.
* verified (and enabled) only x86_64 and arm64; other architectures need to
  be tested, possibly providing own backend.

Some notes:
- in case an architecture doesn't support write rare, the behavior is to
  fallback to regular write operations
- before altering any memory, the destination is sanitized
- write rare data is segregated into own set of pages
- only x86_64 and arm64 verified, atm
- the memset_user() assembly functions seems to work, but I'm not too sure
  they are really ok
- I've added a simple example: the protection of ima_policy_flags
- the last patch is optional, but it seemed worth to do the refactoring
- the x86_64 user space address range is double the size of the kernel
  address space, so it's possible to randomize the beginning of the
  mapping of the kernel address space, but on arm64 they have the same
  size, so it's not possible to do the same. Eventually, the randomization
  could affect exclusively the ranges containing protectable memory, but
  this should be done togeter with the protection of dynamically allocated
  data (once it is available).
- unaddressed: Nadav proposed to do:
	#define __wr          __attribute__((address_space(5)))
  but I don't know exactly where to use it atm

Changelog:

v4->v5
------
* turned conditional inclusion of mm.h into permanent
* added generic, albeit unoptimized memset_user() function
* more verbose error messages for testing of wr_memset()

v3->v4
------

* added function for setting memory in user space mapping for arm64
* refactored code, to work with both supported architectures
* reduced dependency on x86_64 specific code, to support by default also
  arm64
* improved memset_user() for x86_64, but I'm not sure if I understood
  correctly what was the best way to enhance it.

v2->v3
------

* both wr_memset and wr_memcpy are implemented as generic functions
  the arch code must provide suitable helpers
* regular initialization for ima_policy_flags: it happens during init
* remove spurious code from the initialization function

v1->v2
------

* introduce cleaner split between generic and arch code
* add x86_64 specific memset_user()
* replace kernel-space memset() memcopy() with userspace counterpart
* randomize the base address for the alternate map across the entire
  available address range from user space (128TB - 64TB)
* convert BUG() to WARN()
* turn verification of written data into debugging option
* wr_rcu_assign_pointer() as special case of wr_assign()
* example with protection of ima_policy_flags
* documentation

Igor Stoppa (11):
  __wr_after_init: linker section and attribute
  __wr_after_init: Core and default arch
  __wr_after_init: x86_64: randomize mapping offset
  __wr_after_init: x86_64: enable
  __wr_after_init: arm64: enable
  __wr_after_init: Documentation: self-protection
  __wr_after_init: lkdtm test
  __wr_after_init: rodata_test: refactor tests
  __wr_after_init: rodata_test: test __wr_after_init
  __wr_after_init: test write rare functionality
  IMA: turn ima_policy_flags into __wr_after_init

Nadav Amit (1):
  fork: provide a function for copying init_mm

 Documentation/security/self-protection.rst |  14 +-
 arch/Kconfig                               |  22 +++
 arch/arm64/Kconfig                         |   1 +
 arch/x86/Kconfig                           |   1 +
 arch/x86/mm/Makefile                       |   2 +
 arch/x86/mm/prmem.c (new)                  |  20 +++
 drivers/misc/lkdtm/core.c                  |   3 +
 drivers/misc/lkdtm/lkdtm.h                 |   3 +
 drivers/misc/lkdtm/perms.c                 |  29 ++++
 include/asm-generic/vmlinux.lds.h          |  25 +++
 include/linux/cache.h                      |  21 +++
 include/linux/prmem.h (new)                |  70 ++++++++
 include/linux/sched/task.h                 |   1 +
 init/main.c                                |   3 +
 kernel/fork.c                              |  24 ++-
 mm/Kconfig.debug                           |   8 +
 mm/Makefile                                |   2 +
 mm/prmem.c (new)                           | 193 +++++++++++++++++++++
 mm/rodata_test.c                           |  69 +++++---
 mm/test_write_rare.c (new)                 | 142 +++++++++++++++
 security/integrity/ima/ima.h               |   3 +-
 security/integrity/ima/ima_policy.c        |   9 +-
 22 files changed, 628 insertions(+), 37 deletions(-)
 create mode 100644 arch/x86/mm/prmem.c
 create mode 100644 include/linux/prmem.h
 create mode 100644 mm/prmem.c
 create mode 100644 mm/test_write_rare.c

-- 
2.19.1

