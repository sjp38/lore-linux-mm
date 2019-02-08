Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F19AC169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 11:41:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 394F221924
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 11:41:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 394F221924
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rjwysocki.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB9118E008D; Fri,  8 Feb 2019 06:41:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B411A8E008A; Fri,  8 Feb 2019 06:41:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2F328E008D; Fri,  8 Feb 2019 06:41:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 32BD98E008A
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 06:41:26 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id e12-v6so909256ljb.18
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 03:41:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Fgt71OkmjTLzHJg8Lja3uA+fGN3LcOfTeDpEYzVjbOo=;
        b=JPXH37DSacW8P6VraEcyR1/BOwc0/WX/1W5nwM70jrmr1lotoUxVDyek44w4dqYXNT
         hcAfZt0ngMH/WIChoIOJCyZ4XI83l+7Vj13fJ8OxEC2Rys4S5sG3DUpAivrhFDBSx7Iv
         6puAhXDeR22e1MjYMyMV7DuAyk6NMKJ9eypJmPbN3Et0Xh4P5O98W22jXL5fwYyJpaHG
         sXi3lo4obnk2aSrcAIaZl+Q0hwCUMCnSj61yo4UgeJfpBtW5jTaTWPcOKnGzqBg9twzJ
         eOdSZ7yWIp+vaQ7IeuhXV7/PuFumiY+sCf/qCZZ+IvCkdy/3uIOFqpEG7wN7dDMEfc9D
         BIig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjw@rjwysocki.net designates 79.96.170.134 as permitted sender) smtp.mailfrom=rjw@rjwysocki.net
X-Gm-Message-State: AHQUAuaXEw+efD5Qx90lGju8m6YHO/BJgCza66S9SxUB7Hm9EwJGKkVR
	NtYiAQkPsgJRjxDtXpDe70PDbUATb7262oEp6G1i1564O28Cubzd/ekHCKgAZ5x8rsfFh0MCsDE
	mkDxCpM/xSLbvNVPVg1H4qY3uo9AgbBDdQwdxnvXMr7MqrniCF6Tb+siWOye+HOwTBA==
X-Received: by 2002:a2e:9356:: with SMTP id m22-v6mr13265383ljh.135.1549626085373;
        Fri, 08 Feb 2019 03:41:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZFis6FWECKwK/Kamvh+slEiTz0inj7Dm6nP/ER+M4i4Voh2a8IURkW8tWBU4GpPrG9qk89
X-Received: by 2002:a2e:9356:: with SMTP id m22-v6mr13265308ljh.135.1549626083748;
        Fri, 08 Feb 2019 03:41:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549626083; cv=none;
        d=google.com; s=arc-20160816;
        b=H29c3NOkWkXhU23xmFXZPfgSODlAdkhq8FvhgthcEAgHOQcLPVyCpPElA9PTXFrHRV
         WN5HFxfrz1zryTdhrOMXIS39IULcRg3GtuG7bOODLMez6mVIITyODmEJLc1VfR5vMQ1L
         1DCvTKn7TJrpAnEtmcl0g+t4M0aOjB81wGMk+iDL2mcksGRB+iHa90rFEg80uFISIBTc
         XbarnwZV8Eln08/a2MWkUrKDIpM4OEDKQtb27Ldo0+azd0BxPZpo4c6HH8JmaylToA2J
         ObU2//S0Xm+doYa/SiHMhZcNNwVN8v8/5wvjqO9QyCseelsQfl9aFL/TX9hLFDYN3JzS
         39TQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Fgt71OkmjTLzHJg8Lja3uA+fGN3LcOfTeDpEYzVjbOo=;
        b=nv7a1zImUeLxNoP3/pL4lFzaqyZpzpP3/Ow3hV9LCHdTmDAtgOY/h15Nybc19ViP0W
         YEfMeVBDvyKlveveWGftXMEv5tLbPsaLxoR6Z7TGqUb6vQG78NwISdBajLHaLh+kJAQZ
         ie8Y9Gys1To+QdRZcB4/zC34hfWDsWNM7IIR750bqMsf4xEtjKYsBngI8Bm6KnAtxLLJ
         QuvsnbAbRsS1yYlgdUN/91jEsZqOuJ+34eO7M7hfXVQIbzZ5TMUuXSPh0jiY5q0ejA9e
         Wugao47DVTq7jpbUmUgk7peBPtg+N71PsV2iHNutrlpyXJxg5NYcdVSshQokrbDe8/KY
         h4SA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjw@rjwysocki.net designates 79.96.170.134 as permitted sender) smtp.mailfrom=rjw@rjwysocki.net
Received: from cloudserver094114.home.pl (cloudserver094114.home.pl. [79.96.170.134])
        by mx.google.com with ESMTPS id l127si1705987lfg.70.2019.02.08.03.41.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 08 Feb 2019 03:41:23 -0800 (PST)
Received-SPF: pass (google.com: domain of rjw@rjwysocki.net designates 79.96.170.134 as permitted sender) client-ip=79.96.170.134;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjw@rjwysocki.net designates 79.96.170.134 as permitted sender) smtp.mailfrom=rjw@rjwysocki.net
Received: from 79.184.254.36.ipv4.supernova.orange.pl (79.184.254.36) (HELO aspire.rjw.lan)
 by serwer1319399.home.pl (79.96.170.134) with SMTP (IdeaSmtpServer 0.83.183)
 id 7f49cdd1e525bb18; Fri, 8 Feb 2019 12:41:20 +0100
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>
Subject: Re: [PATCH v8 00/26] APEI in_nmi() rework and SDEI wire-up
Date: Fri, 08 Feb 2019 12:40:07 +0100
Message-ID: <15200237.N8Ro7ITLGE@aspire.rjw.lan>
In-Reply-To: <20190129184902.102850-1-james.morse@arm.com>
References: <20190129184902.102850-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday, January 29, 2019 7:48:36 PM CET James Morse wrote:
> Changes since v7?
>  * Removed the memory allocation in the task_work stuff.
>  * More user-friendly and easier on the eye,
>  * Switched the irq-mask testing in the arch code to be safe before&after
>    Julien's GIC PMR series.
> Specific changes are noted in each patch.
> 
> 
> This series aims to wire-up arm64's fancy new software-NMI notifications
> for firmware-first RAS. These need to use the estatus-queue, which is
> also needed for notifications via emulated-SError. All of these
> things take the 'in_nmi()' path through ghes_copy_tofrom_phys(), and
> so will deadlock if they can interact, which they might.
> 
> To that end, this series removes the in_nmi() stuff from ghes.c.
> Locks are pushed out to the notification helpers, and fixmap entries
> are passed in to the code that needs them. This means the estatus-queue
> users can interrupt each other however they like.
> 
> While doing this there is a fair amount of cleanup, which is (now) at the
> beginning of the series. NMIlike notifications interrupting
> ghes_probe() can go wrong for three different reasons. CPER record
> blocks greater than PAGE_SIZE dont' work.
> The estatus-pool allocation is simplified and the silent-flag/oops-begin
> is removed.
> 
> Nothing in this series is intended as fixes, as its all cleanup or
> never-worked.
> 
> ----------%<----------
> The earlier boiler-plate:
> 
> What's SDEI? Its ARM's "Software Delegated Exception Interface" [0]. It's
> used by firmware to tell the OS about firmware-first RAS events.
> 
> These Software exceptions can interrupt anything, so I describe them as
> NMI-like. They aren't the only NMI-like way to notify the OS about
> firmware-first RAS events, the ACPI spec also defines 'NOTFIY_SEA' and
> 'NOTIFY_SEI'.
> 
> (Acronyms: SEA, Synchronous External Abort. The CPU requested some memory,
> but the owner of that memory said no. These are always synchronous with the
> instruction that caused them. SEI, System-Error Interrupt, commonly called
> SError. This is an asynchronous external abort, the memory-owner didn't say no
> at the right point. Collectively these things are called external-aborts
> How is firmware involved? It traps these and re-injects them into the kernel
> once its written the CPER records).
> 
> APEI's GHES code only expects one source of NMI. If a platform implements
> more than one of these mechanisms, APEI needs to handle the interaction.
> 'SEA' and 'SEI' can interact as 'SEI' is asynchronous. SDEI can interact
> with itself: its exceptions can be 'normal' or 'critical', and firmware
> could use both types for RAS. (errors using normal, 'panic-now' using
> critical).
> ----------%<----------
> 
> This series is base on v5.0-rc1, and can be retrieved from:
> git://linux-arm.org/linux-jm.git -b apei_ioremap_rework/v8
> 
> 
> Known issues:
>  * ghes_copy_tofrom_phys() already takes a lock in NMI context, this
>    series moves that around, and makes sure we never try to take the
>    same lock from different NMIlike notifications. Since the switch to
>    queued spinlocks it looks like the kernel can only be 4 context's
>    deep in spinlock, which arm64 could exceed as it doesn't have a
>    single architected NMI. This would be fixed by dropping back to
>    test-and-set when the nesting gets too deep:
>  lore.kernel.org/r/1548215351-18896-1-git-send-email-longman@redhat.com
> 
> * Taking an NMI from a KVM guest on arm64 with VHE leaves HCR_EL2.TGE
>   clear, meaning AT and TLBI point at the guest, and PAN/UAO are squiffy.
>   Only TLBI matters for APEI, and this is fixed by Julien's patch:
>  http://lore.kernel.org/r/1548084825-8803-2-git-send-email-julien.thierry@arm.com
> 
> * Linux ignores the physical address mask, meaning it doesn't call
>   memory_failure() on all the affected pages if firmware or hypervisor
>   believe in a different page size. Easy to hit on arm64, (easy to fix too,
>   it just conflicts with this series)
> 
> 
> [v7] https://lore.kernel.org/linux-arm-kernel/20181203180613.228133-1-james.morse@arm.com/
> [v6] https://www.spinics.net/lists/linux-acpi/msg84228.html
> [v5] https://www.spinics.net/lists/linux-acpi/msg82993.html
> [v4] https://www.spinics.net/lists/arm-kernel/msg653078.html
> [v3] https://www.spinics.net/lists/arm-kernel/msg649230.html
> 
> [0] https://static.docs.arm.com/den0054/a/ARM_DEN0054A_Software_Delegated_Exception_Interface.pdf
> 
> 
> James Morse (26):
>   ACPI / APEI: Don't wait to serialise with oops messages when
>     panic()ing
>   ACPI / APEI: Remove silent flag from ghes_read_estatus()
>   ACPI / APEI: Switch estatus pool to use vmalloc memory
>   ACPI / APEI: Make hest.c manage the estatus memory pool
>   ACPI / APEI: Make estatus pool allocation a static size
>   ACPI / APEI: Don't store CPER records physical address in struct ghes
>   ACPI / APEI: Remove spurious GHES_TO_CLEAR check
>   ACPI / APEI: Don't update struct ghes' flags in read/clear estatus
>   ACPI / APEI: Generalise the estatus queue's notify code
>   ACPI / APEI: Don't allow ghes_ack_error() to mask earlier errors
>   ACPI / APEI: Move NOTIFY_SEA between the estatus-queue and NOTIFY_NMI
>   ACPI / APEI: Switch NOTIFY_SEA to use the estatus queue
>   KVM: arm/arm64: Add kvm_ras.h to collect kvm specific RAS plumbing
>   arm64: KVM/mm: Move SEA handling behind a single 'claim' interface
>   ACPI / APEI: Move locking to the notification helper
>   ACPI / APEI: Let the notification helper specify the fixmap slot
>   ACPI / APEI: Pass ghes and estatus separately to avoid a later copy
>   ACPI / APEI: Make GHES estatus header validation more user friendly
>   ACPI / APEI: Split ghes_read_estatus() to allow a peek at the CPER
>     length
>   ACPI / APEI: Only use queued estatus entry during
>     in_nmi_queue_one_entry()
>   ACPI / APEI: Use separate fixmap pages for arm64 NMI-like
>     notifications
>   mm/memory-failure: Add memory_failure_queue_kick()
>   ACPI / APEI: Kick the memory_failure() queue for synchronous errors
>   arm64: acpi: Make apei_claim_sea() synchronise with APEI's irq work
>   firmware: arm_sdei: Add ACPI GHES registration helper
>   ACPI / APEI: Add support for the SDEI GHES Notification type
> 
>  arch/arm/include/asm/kvm_ras.h       |  14 +
>  arch/arm/include/asm/system_misc.h   |   5 -
>  arch/arm64/include/asm/acpi.h        |   4 +-
>  arch/arm64/include/asm/daifflags.h   |   1 +
>  arch/arm64/include/asm/fixmap.h      |   6 +-
>  arch/arm64/include/asm/kvm_ras.h     |  25 +
>  arch/arm64/include/asm/system_misc.h |   2 -
>  arch/arm64/kernel/acpi.c             |  54 ++
>  arch/arm64/mm/fault.c                |  25 +-
>  drivers/acpi/apei/Kconfig            |  12 +-
>  drivers/acpi/apei/ghes.c             | 725 ++++++++++++++++-----------
>  drivers/acpi/apei/hest.c             |  10 +-
>  drivers/firmware/arm_sdei.c          |  68 +++
>  include/acpi/ghes.h                  |   7 +-
>  include/linux/arm_sdei.h             |   9 +
>  include/linux/mm.h                   |   1 +
>  mm/memory-failure.c                  |  15 +-
>  virt/kvm/arm/mmu.c                   |   4 +-
>  18 files changed, 646 insertions(+), 341 deletions(-)
>  create mode 100644 arch/arm/include/asm/kvm_ras.h
>  create mode 100644 arch/arm64/include/asm/kvm_ras.h

I can apply patches in this series up to and including patch [21/26].

Do you want me to do that?

Patch [22/26] requires an ACK from mm people.

Patch [23/26] has a problem that randconfig can generate a configuration
in which memory_failure_queue_kick() is not present, so it is necessary
to add a CONFIG_MEMORY_FAILURE dependency somewhere for things to
work (or define an empty stub for that function in case the symbol is
not set).

If patches [24-26/26] don't depend on the previous two, I can try to
apply them either, so please let me know.

Thanks,
Rafael

