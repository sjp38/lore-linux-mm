Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD333C10F0E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 19:21:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A98EF2075E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 19:21:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A98EF2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49CE86B000E; Thu,  4 Apr 2019 15:21:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44C516B0266; Thu,  4 Apr 2019 15:21:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33C9E6B0269; Thu,  4 Apr 2019 15:21:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E52636B000E
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 15:21:09 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 102so2348914plb.20
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 12:21:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=LcA9VW3JhYSBvWgeKoY4OmuKsMNYpNO0kt/2KV0Vtxo=;
        b=gJRTWIu1QGZdko/FDuwiwwlaXFynwyNDsXYql8e1QKQfsxf/56/Q2ELfkHR4S7d4Or
         mpVuIzIlEP84kJkxfcx87gtHo46o96SoznKfzOZM8fWGrqQwxJhkQ9JyuraftJDWr6hi
         4uvFolmp/ZOcJ6cQLvYehra0Ocm3q3gcR/xlym8sxrX4pH9G4CprPupgpXXwaAb2QKHS
         Ip0R3hEfm0kPWC9u0MozdKm4htUuvniASoErNygiwfJWnFF1S82dLlqB1dc0z4bzpr9t
         shwoCPgG2XWAcOTP9wgMV1EN9oUYq9dSU26S7SM78pJden/zaDa2aTPa2qw8PUCHqyQo
         xvOQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXLB5szpv73TyRv6tiuemjaaRtuV4LlwQwKkCJi+jHcbZLdo+IZ
	7U0bP23VNuqpY4VNYGDX7civgg/qjydRc/dFijYF6HkMICGC6hi8PGm8T7jzi8Fi4Px8UdAnZRD
	jemyLGp9N212BknavzHdjYWfsVtqxr5rymYzMnaCAnj3pOS/fDn4UKdjyLxuukQD+9g==
X-Received: by 2002:a63:403:: with SMTP id 3mr3934281pge.335.1554405669462;
        Thu, 04 Apr 2019 12:21:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx35+If+2U9T/8NShhVxD/sDCXgDgAN3xtQV0ACYN8ygD3XGnEN2Y+dXNeigw62bbRhEChV
X-Received: by 2002:a63:403:: with SMTP id 3mr3934202pge.335.1554405668304;
        Thu, 04 Apr 2019 12:21:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554405668; cv=none;
        d=google.com; s=arc-20160816;
        b=YfQquRj3xBAecZEIP/3pdOHm+JwAreiGrdPsoFPXmbUEMIYjoKZ6+4b8g40g56J7gN
         jWhf5lZTgFNRPQqHhYtK6VGsa+XoZA4IcSBH4S6bUu7qXLB63UP9z4RtNCNB47Gp4eR/
         26DAFsfOYIx1Bi9wdVFoN9ve5yw0GUc0qBUm4H38c1OzBQvW17wDraiy6qHSTI2dX9wQ
         xRyUF98bdVEVJ7pAtuweDBV1s+oGil0FjEGtw3oE/Dlaermqcbb2kedUyfSYgHSJzOvB
         4TGBQb64hxLg9fSvXSQIJJzXbpuT6sxPYkJhBE62nOt5fE+B/IDyCqs16aMuWyzfXJwf
         QOKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=LcA9VW3JhYSBvWgeKoY4OmuKsMNYpNO0kt/2KV0Vtxo=;
        b=BjbFDyzji1a2J6wJcllS5q49Tw+OgG2rXbvabEfBzrBbWncIIUx6pMp9izah0CgTCg
         T01l5rKWD7h+kJ4EvJXSoD8RKJ43FF99G6kJdbF4nCgBg7fKr9910ZmW3fSAJZgx3A0r
         r/vJ2lwfW1qc0ikn5l9bS54tzVOY9sRYbGxpuk0Po9m+PIVnCaY9S9cTVwBRmrW/7wUP
         gVG1Anqa+cD5VyfAJCJ/qbzsy3WHh78/9Sgt+s1AExjKfSfbommIWA9dTXexlPhc9UEf
         LzXCLfC5Yu2NdQE9CWJgsCGVvj0JQuqNLVrQEA0panUFxaC0IN5eFO4zcTviIoS7n5Ze
         +O5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id i3si16432230pgq.282.2019.04.04.12.21.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 12:21:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Apr 2019 12:21:07 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,309,1549958400"; 
   d="scan'208";a="128686099"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga007.jf.intel.com with ESMTP; 04 Apr 2019 12:21:07 -0700
Subject: [RFC PATCH 0/5] EFI Special Purpose Memory Support
From: Dan Williams <dan.j.williams@intel.com>
To: linux-kernel@vger.kernel.org
Cc: Dave Jiang <dave.jiang@intel.com>, Keith Busch <keith.busch@intel.com>,
 Andy Shevchenko <andy@infradead.org>, Borislav Petkov <bp@alien8.de>,
 Vishal Verma <vishal.l.verma@intel.com>, "H. Peter Anvin" <hpa@zytor.com>,
 Thomas Gleixner <tglx@linutronix.de>,
 Jonathan Cameron <Jonathan.Cameron@huawei.com>, Ingo Molnar <mingo@redhat.com>,
 Len Brown <lenb@kernel.org>, Darren Hart <dvhart@infradead.org>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 "Rafael J. Wysocki" <rjw@rjwysocki.net>, x86@kernel.org, linux-mm@kvack.org,
 keith.busch@intel.com, vishal.l.verma@intel.com, linux-nvdimm@lists.01.org
Date: Thu, 04 Apr 2019 12:08:28 -0700
Message-ID: <155440490809.3190322.15060922240602775809.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The EFI 2.8 Specification [1] introduces the EFI_MEMORY_SP ("special
purpose") memory attribute. This attribute bit replaces the deprecated
"reservation hint" that was introduced in ACPI 6.2 and removed in ACPI
6.3.

Given the increasing diversity of memory types that might be advertised
to the operating system, there is a need for platform firmware to hint
which memory ranges are free for the OS to use as general purpose memory
and which ranges are intended for application specific usage. For
example, an application with prior knowledge of the platform may expect
to be able to exclusively allocate a precious / limited pool of high
bandwidth memory. Alternatively, for the general purpose case, the
operating system may want to make the memory available on a best effort
basis as a unique numa-node with performance properties by the new
CONFIG_HMEM_REPORTING [2] facility.

In support of allowing for both exclusive and core-kernel-mm managed
access to differentiated memory, claim EFI_MEMORY_SP ranges for exposure
as device-dax instances by default. Those instances can be directly
owned / mapped by a platform-topology-aware application. However, with
the new kmem facility [3], the administrator has the option to instead
designate that those memory ranges be hot-added to the core-kernel-mm as
a unique memory numa-node. In short, allow for the decision about what
software agent manages special purpose memory to be made at runtime.

The patches are based on v8 of Keith's "HMEM" series currently in Greg's
driver-core-testing branch [4], and have not been tested. This is an RFC
proposal on how to handle the new EFI memory attribute.

[1]: https://uefi.org/sites/default/files/resources/UEFI_Spec_2_8_final.pdf
[2]: https://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core.git/commit/?h=driver-core-testing&id=b6efba75c449
[3]: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c221c0b0308f
[4]: https://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core.git/log/?h=driver-core-testing

---

Dan Williams (5):
      efi: Detect UEFI 2.8 Special Purpose Memory
      lib/memregion: Uplevel the pmem "region" ida to a global allocator
      acpi/hmat: Track target address ranges
      acpi/hmat: Register special purpose memory as a device
      device-dax: Add a driver for "hmem" devices


 arch/x86/Kconfig                  |   18 +++++
 arch/x86/boot/compressed/eboot.c  |    5 +
 arch/x86/boot/compressed/kaslr.c  |    2 -
 arch/x86/include/asm/e820/types.h |    9 ++
 arch/x86/kernel/e820.c            |    9 ++
 arch/x86/platform/efi/efi.c       |   10 ++-
 drivers/acpi/hmat/Kconfig         |    1 
 drivers/acpi/hmat/hmat.c          |  140 +++++++++++++++++++++++++++++++------
 drivers/dax/Kconfig               |   26 ++++++-
 drivers/dax/Makefile              |    2 +
 drivers/dax/hmem.c                |   58 +++++++++++++++
 drivers/nvdimm/Kconfig            |    1 
 drivers/nvdimm/core.c             |    1 
 drivers/nvdimm/nd-core.h          |    1 
 drivers/nvdimm/region_devs.c      |   13 +--
 include/linux/efi.h               |   14 ++++
 include/linux/ioport.h            |    1 
 include/linux/memregion.h         |    9 ++
 lib/Kconfig                       |    6 ++
 lib/Makefile                      |    1 
 lib/memregion.c                   |   22 ++++++
 21 files changed, 304 insertions(+), 45 deletions(-)
 create mode 100644 drivers/dax/hmem.c
 create mode 100644 include/linux/memregion.h
 create mode 100644 lib/memregion.c

