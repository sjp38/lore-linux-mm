Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CBC8C282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:28:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C37F2184E
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:28:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="d4gPdAkI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C37F2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7C598E0191; Mon, 11 Feb 2019 18:28:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2C3B8E0189; Mon, 11 Feb 2019 18:28:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F90F8E0191; Mon, 11 Feb 2019 18:28:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4AF698E0189
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:28:07 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id s5so226889wrp.17
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:28:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:reply-to:mime-version:content-transfer-encoding;
        bh=WiVvqtIRSUTlDM0fLGtak+4fmHxmqyUWRnseuvynyBA=;
        b=L0Y2a7J4Ep+o4eBMnBmMuP6DuSX37iLTgPhe0SuQOAa/jATS0fIPLsxXtQBQbpVacV
         /em8YnjMcD/Ko+JVrL6CbFVRbkT0HfAy5eHxWZ/iCCBPdNttM7ehlJA4hN0XY94bqqC6
         K+SacWkAXp8z9OvELPok3ouVkaMXboJiNu03oflaVJD1U7bO2UIaxyDXI5AbepoR717r
         Fk3AhlhKLLsQIiWhxn+MlVeUcR/34wKLCBjMGBBP8pKeM5rvFKTLwJExVnBqEYDUnoUn
         I1Y6uGBNnhpF5sDLw457eDBDk0RlHaWmNwJU+AAeicdgIJ1HUuDAKwseDkFF+XKQhRQj
         XYPw==
X-Gm-Message-State: AHQUAuatKz9zvyKfwe4E9sVPsJ0q4/bsnsDRjGrJniAWGhM+zsLH9jd3
	KmsagLFU+9J4aaoyQkLVO8XILWl+OK/CakFKXup1CJ71GfgDbSo+uOkvd0h35UUIRGSjWn3bY/b
	ZscdE+Disi3tFxF41QmPrGHwOrhZt17WZy+hD3OvXznvV3URQkT1sg30pYE/xBBNzb5P8OCvwsq
	ZCzQJAYuJi9e+JpKx9FdFalzZPjD35J81hAu0O/yz9D7FuDZmxcQiO24bJMmbWzAGAWuZNHBrrd
	PT0SN4V1tPGg4A8RA/HCroDzfSIye4JKrYbQqKre4P6HUR/jLZ00BPXRtf5uJ5TmC5R/m8CBdpd
	R/eumq2SR/h/AdO1QhsD3rEV2RzRobDPF9Ni+vUnSB7x62PmLctqGw4un0K3TDgIaTdXTXmkkrl
	0
X-Received: by 2002:adf:8273:: with SMTP id 106mr533070wrb.34.1549927686782;
        Mon, 11 Feb 2019 15:28:06 -0800 (PST)
X-Received: by 2002:adf:8273:: with SMTP id 106mr532998wrb.34.1549927685216;
        Mon, 11 Feb 2019 15:28:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549927685; cv=none;
        d=google.com; s=arc-20160816;
        b=xW6kKPptD21wm7hEPcE9pzQqWJ6hDroPA9kmXiMUaXw5RSqZGV9zvIV0YJslBO5VC/
         iwr9aTGuPtucNACDBcwtcWEr/37KFwaF0KE/n/ll60apSbXt2bnvx3cAPfdg2vWs11Bp
         uGefL9447jmxd53WZthBpPsWx3VaZ6jkHoGzCEWuObsStqpQ49qJrgjeQ38yXiFVUJqh
         CimHiU05pKDUE3eI5mUo8Gk2KhSKWPFfFHxxINy2Nz6B/f85W6mAW1I5MZsUQrhe9nYa
         0ZEKypn9RgUvM5/qUbQEBItCyZJCIWAsdKz0WRF9FL/UKZP+SIve2d7i4oQ2/Hx0X47g
         qakw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=WiVvqtIRSUTlDM0fLGtak+4fmHxmqyUWRnseuvynyBA=;
        b=N2Q4LepnL+NXffnGC9AR5mXnBIFShIQwy8XCIJ0FGH1PhP+uiEiYp2dTOD9bc7j5yx
         62RGNLYLxEcDhvlfTgFB3cOgFqbMrmWYZ26R2OI2lqnD/g2oZ1G2RHiaUr1nSv8wOUmW
         eZkn0F0ITQGx+PBVce9cRVzRiJXzwZ6I3nxqBvJoxrivhRNvWtfiCPWz/Ck8N1r+TqtK
         BRihfoACgWfgGl2ZG5Yx0RzptG+x7ac2sgDAmhP6Ix5TVgu617h5HZGpR6H1GjBoIiMj
         2UIitR9WyzGIMSPfzLjpJB+REChUuCedd991tj96XymKUYHXAGLaG35snoHqMpp1YwB/
         uzZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=d4gPdAkI;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d7sor3667999wrx.34.2019.02.11.15.28.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 15:28:05 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=d4gPdAkI;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:reply-to:mime-version
         :content-transfer-encoding;
        bh=WiVvqtIRSUTlDM0fLGtak+4fmHxmqyUWRnseuvynyBA=;
        b=d4gPdAkIB5pcxMqazVlY0aM9rShWWD8ZDlRnMRbsHx1ZqP5f2pl+Ud860bl0tKxLPW
         lW5JbjgFkyDiqpSm3g3L/XFha+LtJ3vvWR5GIb8lRlNMN6YQHZshn9hmiCRZphaxRMGy
         3iz4GkDL9y7IaUkAPRdBozhH4zzVRtCzyYdeFtUa86M2kRCNUqT8oPaKdNM+MnrKHTJO
         tQQY/zPwJJFOmEi1gndbn94fxfgRr5xbm9OwG7k7UI5mV8FQgYMqTR15xzUgHKUL+OkC
         ZgUG0YNWA8Sulsrjd9Um5S/sgIpGcYLoeJsulbdZqvF63WjvEkkMl0eaF82ofcpv4gDO
         9N/g==
X-Google-Smtp-Source: AHgI3IYYK161pUzr6asXVXNX2dxWTZn19D/paOND9eEjGNQtMhZwuiEhs0iHU0hAE6PbKZCUdlK/KA==
X-Received: by 2002:adf:e8c7:: with SMTP id k7mr508447wrn.298.1549927684722;
        Mon, 11 Feb 2019 15:28:04 -0800 (PST)
Received: from localhost.localdomain (bba134232.alshamil.net.ae. [217.165.113.120])
        by smtp.gmail.com with ESMTPSA id e67sm1470295wmg.1.2019.02.11.15.28.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 15:28:03 -0800 (PST)
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
Subject: [RFC PATCH v4 00/12] hardening: statically allocated protected memory
Date: Tue, 12 Feb 2019 01:27:37 +0200
Message-Id: <cover.1549927666.git.igor.stoppa@huawei.com>
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
at last I'm able to resume work on the memory protection patchset I've
proposed some time ago. This version should address comments received so
far and introduce support for arm64. Details below.

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
* supports only x86_64 and arm64;other architectures need to provide own
  backend

Some notes:
- in case an architecture doesn't support write rare, the behavior is to
  fallback to regular write operations
- before altering any memory, the destination is sanitized
- write rare data is segregated into own set of pages
- only x86_64 and arm64 supported, atm
- the memset_user() assembly functions seems to work, but I'm not too sure
  they are really ok
- I've added a simple example: the protection of ima_policy_flags
- the last patch is optional, but it seemed worth to do the refactoring
- the x86_64 user space address range is double the size of the kernel
  address space, so it's possible to randomize the beginning of the
  mapping of the kernel address space, but on arm64 they have the same
  size, so it's not possible to do the same
- I'm not sure if it's correct, since it doesn't seem to be that common in
  kernel sources, but instead of using #defines for overriding default
  function calls, I'm using "weak" for the default functions.
- unaddressed: Nadav proposed to do:
	#define __wr          __attribute__((address_space(5)))
  but I don't know exactly where to use it atm

Changelog:

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

Igor Stoppa (12):
  __wr_after_init: Core and default arch
  __wr_after_init: x86_64: memset_user()
  __wr_after_init: x86_64: randomize mapping offset
  __wr_after_init: x86_64: enable
  __wr_after_init: arm64: memset_user()
  __wr_after_init: arm64: enable
  __wr_after_init: Documentation: self-protection
  __wr_after_init: lkdtm test
  __wr_after_init: rodata_test: refactor tests
  __wr_after_init: rodata_test: test __wr_after_init
  __wr_after_init: test write rare functionality
  IMA: turn ima_policy_flags into __wr_after_init

 Documentation/security/self-protection.rst |  14 +-
 arch/Kconfig                               |   7 +
 arch/arm64/Kconfig                         |   1 +
 arch/arm64/include/asm/uaccess.h           |   9 ++
 arch/arm64/lib/Makefile                    |   2 +-
 arch/arm64/lib/memset_user.S (new)         |  63 ++++++++
 arch/x86/Kconfig                           |   1 +
 arch/x86/include/asm/uaccess_64.h          |   6 +
 arch/x86/lib/usercopy_64.c                 |  51 ++++++
 arch/x86/mm/Makefile                       |   2 +
 arch/x86/mm/prmem.c (new)                  |  20 +++
 drivers/misc/lkdtm/core.c                  |   3 +
 drivers/misc/lkdtm/lkdtm.h                 |   3 +
 drivers/misc/lkdtm/perms.c                 |  29 ++++
 include/linux/prmem.h (new)                |  71 ++++++++
 mm/Kconfig.debug                           |   8 +
 mm/Makefile                                |   2 +
 mm/prmem.c (new)                           | 179 +++++++++++++++++++++
 mm/rodata_test.c                           |  69 +++++---
 mm/test_write_rare.c (new)                 | 136 ++++++++++++++++
 security/integrity/ima/ima.h               |   3 +-
 security/integrity/ima/ima_policy.c        |   9 +-
 22 files changed, 656 insertions(+), 32 deletions(-)
 create mode 100644 arch/arm64/lib/memset_user.S
 create mode 100644 arch/x86/mm/prmem.c
 create mode 100644 include/linux/prmem.h
 create mode 100644 mm/prmem.c
 create mode 100644 mm/test_write_rare.c

-- 
2.19.1

