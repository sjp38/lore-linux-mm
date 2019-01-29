Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 509E1C282C7
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:49:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 105082087F
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:49:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 105082087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B746D8E0005; Tue, 29 Jan 2019 13:49:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B23B68E0001; Tue, 29 Jan 2019 13:49:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A12F08E0005; Tue, 29 Jan 2019 13:49:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 465E48E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:49:18 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c3so8433253eda.3
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:49:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=XCRl+wnjLra5hUYA4B/MjapdfavrKd70VTHeahZ9u54=;
        b=iIDsYsFdMErIkbzWSMDq741VAraftV4/brCvN0yfDUZ6xKwY24SglbiNjafVHavviX
         wa0ZMMJJQDqTKYzZdOveZHvQslgbvYoVukVatyVhWE2DG82GUwgd26IfsgAUadJrmjX/
         AIarBgJ8zNWyFBSlA6+A1OYr/+AVg9EiLLWezJiuk0juBgxzh4Pxpj1bDsgZda6mZPjV
         Qln84C6DCS6XBbGvz/j/nZ1vCYjz0MrJTM4gc3TdKGl8ws7YZImKoExmNZIZ9+kK4660
         Z8M+PcKF+q7ADSpHGdzVphKqtciUtGSupl1sZ+0SWqKJ/vA6vXVNBcb17okFGGXXFY27
         Wj5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukc+UKgxquI0dqn0S+yumxZ/GzOtBOcpKvTynVyvqXZNjGDgPqcL
	wo2LVx1VVKM+gHjS86/EZ6urjeaqgERCMMk/gDihajEjSOptpq6wjdYxnv0D0NvLt7zcJ+a4ftV
	4l3lxPOHuyYIkXmxiFpTg4p6e2N+wVt0k/qqorDtcOu1XRCvj7G0cZ/hJCptZ8lY3TQ==
X-Received: by 2002:a50:a6cf:: with SMTP id f15mr26041180edc.97.1548787757752;
        Tue, 29 Jan 2019 10:49:17 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7wMalI0Ei8NyioO/QDrRKUo0yN/ziWCdrhryUZOsXnVWfeGguPCd7qjOtoxMVJpl83iEVc
X-Received: by 2002:a50:a6cf:: with SMTP id f15mr26041110edc.97.1548787756410;
        Tue, 29 Jan 2019 10:49:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787756; cv=none;
        d=google.com; s=arc-20160816;
        b=geE229jkzVO6swPaXa8Ptn0tclkD7fdB1c1xS0Q7mIrRaNjCoTYD5PPrh1zbPJOEgs
         unTyu58BJxqFw24Wk7w7Ah4q0418lh5VXMvWduGg5Qka82nrcW9/v6DzX2s6BLqeCKuM
         Rc67BQqu3n4tUPalhtcbGrcdureZJ5O5u2jSziAAAZK0Ac2nH0t4kPo9MJXlKF63UBeP
         aOKkveb0bzgnYL2Z27byNzL+2RGKhCP7BpRGqc+eg7goCxWWaRColjShH1SLK7HdNW97
         wMlJQi3jZtyDFmi/KeppdgsSXgKntfEh6cK/8eeYHDNQL7c2kvXLP5yCsGZyyRYjtBgF
         G6hQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=XCRl+wnjLra5hUYA4B/MjapdfavrKd70VTHeahZ9u54=;
        b=DCDpr4gseTnYHfw3ggyD04EwScdM+MGUIXAOcNLJoRz1uGOo/T62b2/VJ5cQTUDtQn
         UppYTizxtJgaDT+jsgZvTcMIPOWvjvmD2t+lTXL7o7ijX7RDj73mDzlWlDlLoD3jVEty
         PteaC6TczMVgXYX3DVAeZWaXI5y0XiQpokreg/HWabHefHSnB7pHj4gPjE4tv6ts7u8d
         GdjxvmExlH/5u/w3eBjhTnBI0j3jXO5EtdbbqbmcxB00XqV1riOUBIo6eVN1a5cZXl8J
         QEd8tq0IJVUPYL8uryMUxc5vW/q+vWQhoYV+FThuMLLbyCNjXKA3YeJmJgVWuHoOuYSn
         C61g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l25si1019480edd.87.2019.01.29.10.49.15
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:49:16 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 43EE8A78;
	Tue, 29 Jan 2019 10:49:15 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 96A7C3F557;
	Tue, 29 Jan 2019 10:49:12 -0800 (PST)
From: James Morse <james.morse@arm.com>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	Borislav Petkov <bp@alien8.de>,
	Marc Zyngier <marc.zyngier@arm.com>,
	Christoffer Dall <christoffer.dall@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Rafael Wysocki <rjw@rjwysocki.net>,
	Len Brown <lenb@kernel.org>,
	Tony Luck <tony.luck@intel.com>,
	Dongjiu Geng <gengdongjiu@huawei.com>,
	Xie XiuQi <xiexiuqi@huawei.com>,
	james.morse@arm.com
Subject: [PATCH v8 00/26] APEI in_nmi() rework and SDEI wire-up
Date: Tue, 29 Jan 2019 18:48:36 +0000
Message-Id: <20190129184902.102850-1-james.morse@arm.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes since v7?
 * Removed the memory allocation in the task_work stuff.
 * More user-friendly and easier on the eye,
 * Switched the irq-mask testing in the arch code to be safe before&after
   Julien's GIC PMR series.
Specific changes are noted in each patch.


This series aims to wire-up arm64's fancy new software-NMI notifications
for firmware-first RAS. These need to use the estatus-queue, which is
also needed for notifications via emulated-SError. All of these
things take the 'in_nmi()' path through ghes_copy_tofrom_phys(), and
so will deadlock if they can interact, which they might.

To that end, this series removes the in_nmi() stuff from ghes.c.
Locks are pushed out to the notification helpers, and fixmap entries
are passed in to the code that needs them. This means the estatus-queue
users can interrupt each other however they like.

While doing this there is a fair amount of cleanup, which is (now) at the
beginning of the series. NMIlike notifications interrupting
ghes_probe() can go wrong for three different reasons. CPER record
blocks greater than PAGE_SIZE dont' work.
The estatus-pool allocation is simplified and the silent-flag/oops-begin
is removed.

Nothing in this series is intended as fixes, as its all cleanup or
never-worked.

----------%<----------
The earlier boiler-plate:

What's SDEI? Its ARM's "Software Delegated Exception Interface" [0]. It's
used by firmware to tell the OS about firmware-first RAS events.

These Software exceptions can interrupt anything, so I describe them as
NMI-like. They aren't the only NMI-like way to notify the OS about
firmware-first RAS events, the ACPI spec also defines 'NOTFIY_SEA' and
'NOTIFY_SEI'.

(Acronyms: SEA, Synchronous External Abort. The CPU requested some memory,
but the owner of that memory said no. These are always synchronous with the
instruction that caused them. SEI, System-Error Interrupt, commonly called
SError. This is an asynchronous external abort, the memory-owner didn't say no
at the right point. Collectively these things are called external-aborts
How is firmware involved? It traps these and re-injects them into the kernel
once its written the CPER records).

APEI's GHES code only expects one source of NMI. If a platform implements
more than one of these mechanisms, APEI needs to handle the interaction.
'SEA' and 'SEI' can interact as 'SEI' is asynchronous. SDEI can interact
with itself: its exceptions can be 'normal' or 'critical', and firmware
could use both types for RAS. (errors using normal, 'panic-now' using
critical).
----------%<----------

This series is base on v5.0-rc1, and can be retrieved from:
git://linux-arm.org/linux-jm.git -b apei_ioremap_rework/v8


Known issues:
 * ghes_copy_tofrom_phys() already takes a lock in NMI context, this
   series moves that around, and makes sure we never try to take the
   same lock from different NMIlike notifications. Since the switch to
   queued spinlocks it looks like the kernel can only be 4 context's
   deep in spinlock, which arm64 could exceed as it doesn't have a
   single architected NMI. This would be fixed by dropping back to
   test-and-set when the nesting gets too deep:
 lore.kernel.org/r/1548215351-18896-1-git-send-email-longman@redhat.com

* Taking an NMI from a KVM guest on arm64 with VHE leaves HCR_EL2.TGE
  clear, meaning AT and TLBI point at the guest, and PAN/UAO are squiffy.
  Only TLBI matters for APEI, and this is fixed by Julien's patch:
 http://lore.kernel.org/r/1548084825-8803-2-git-send-email-julien.thierry@arm.com

* Linux ignores the physical address mask, meaning it doesn't call
  memory_failure() on all the affected pages if firmware or hypervisor
  believe in a different page size. Easy to hit on arm64, (easy to fix too,
  it just conflicts with this series)


[v7] https://lore.kernel.org/linux-arm-kernel/20181203180613.228133-1-james.morse@arm.com/
[v6] https://www.spinics.net/lists/linux-acpi/msg84228.html
[v5] https://www.spinics.net/lists/linux-acpi/msg82993.html
[v4] https://www.spinics.net/lists/arm-kernel/msg653078.html
[v3] https://www.spinics.net/lists/arm-kernel/msg649230.html

[0] https://static.docs.arm.com/den0054/a/ARM_DEN0054A_Software_Delegated_Exception_Interface.pdf


James Morse (26):
  ACPI / APEI: Don't wait to serialise with oops messages when
    panic()ing
  ACPI / APEI: Remove silent flag from ghes_read_estatus()
  ACPI / APEI: Switch estatus pool to use vmalloc memory
  ACPI / APEI: Make hest.c manage the estatus memory pool
  ACPI / APEI: Make estatus pool allocation a static size
  ACPI / APEI: Don't store CPER records physical address in struct ghes
  ACPI / APEI: Remove spurious GHES_TO_CLEAR check
  ACPI / APEI: Don't update struct ghes' flags in read/clear estatus
  ACPI / APEI: Generalise the estatus queue's notify code
  ACPI / APEI: Don't allow ghes_ack_error() to mask earlier errors
  ACPI / APEI: Move NOTIFY_SEA between the estatus-queue and NOTIFY_NMI
  ACPI / APEI: Switch NOTIFY_SEA to use the estatus queue
  KVM: arm/arm64: Add kvm_ras.h to collect kvm specific RAS plumbing
  arm64: KVM/mm: Move SEA handling behind a single 'claim' interface
  ACPI / APEI: Move locking to the notification helper
  ACPI / APEI: Let the notification helper specify the fixmap slot
  ACPI / APEI: Pass ghes and estatus separately to avoid a later copy
  ACPI / APEI: Make GHES estatus header validation more user friendly
  ACPI / APEI: Split ghes_read_estatus() to allow a peek at the CPER
    length
  ACPI / APEI: Only use queued estatus entry during
    in_nmi_queue_one_entry()
  ACPI / APEI: Use separate fixmap pages for arm64 NMI-like
    notifications
  mm/memory-failure: Add memory_failure_queue_kick()
  ACPI / APEI: Kick the memory_failure() queue for synchronous errors
  arm64: acpi: Make apei_claim_sea() synchronise with APEI's irq work
  firmware: arm_sdei: Add ACPI GHES registration helper
  ACPI / APEI: Add support for the SDEI GHES Notification type

 arch/arm/include/asm/kvm_ras.h       |  14 +
 arch/arm/include/asm/system_misc.h   |   5 -
 arch/arm64/include/asm/acpi.h        |   4 +-
 arch/arm64/include/asm/daifflags.h   |   1 +
 arch/arm64/include/asm/fixmap.h      |   6 +-
 arch/arm64/include/asm/kvm_ras.h     |  25 +
 arch/arm64/include/asm/system_misc.h |   2 -
 arch/arm64/kernel/acpi.c             |  54 ++
 arch/arm64/mm/fault.c                |  25 +-
 drivers/acpi/apei/Kconfig            |  12 +-
 drivers/acpi/apei/ghes.c             | 725 ++++++++++++++++-----------
 drivers/acpi/apei/hest.c             |  10 +-
 drivers/firmware/arm_sdei.c          |  68 +++
 include/acpi/ghes.h                  |   7 +-
 include/linux/arm_sdei.h             |   9 +
 include/linux/mm.h                   |   1 +
 mm/memory-failure.c                  |  15 +-
 virt/kvm/arm/mmu.c                   |   4 +-
 18 files changed, 646 insertions(+), 341 deletions(-)
 create mode 100644 arch/arm/include/asm/kvm_ras.h
 create mode 100644 arch/arm64/include/asm/kvm_ras.h

-- 
2.20.1

