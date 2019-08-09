Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD2E3C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:00:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52D3A2089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:00:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52D3A2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B41226B0003; Fri,  9 Aug 2019 12:00:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF1356B0006; Fri,  9 Aug 2019 12:00:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B9076B0007; Fri,  9 Aug 2019 12:00:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 460AD6B0003
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:00:48 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id i6so46679071wre.1
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:00:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=Hgau3dPaYW7ICltIfI18zpDXvENxPnAvUGUSy8Yw3r8=;
        b=c0yAOIGC1Dk6+mF1BPU5wZE4HIrZkhQFYmnEurgUUOs2t0HwnvRRsy20+FTAI6/Ngt
         d0VMMX9IQEPgAxK5Hr2LdEq/3s2I8qGYE2YQLAzHg0tzEsJLccS5fgKWh2wUE5ih5yWC
         Hbwzna4TkcRfY1NCWeStNOyqGGZ3CEsjPwX3BLKcsX6MGNC/8ZdlamQ1fy21L3CIB4vJ
         LSDlxmsnFfrC8u2EpYC635gYvJ4ZmaQtH+/xcxMOQFtq/cCTsfHWlvAYk/cjwxIXkzXA
         NWXTcc2caYG7oxHV06RzAOf3WFSFsT3aNEvFoZsUsiQG0jvllw8XAFKYlHlIulU7HTUo
         X3Yw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAXzWuuOCkFm2kmj4SiPwPHjFyODTVlxNObKxnJMUSL28gssRkdZ
	8ErMcM2DXSTM/KJ6BYzp+qbH/gf480M3M+3+3Pl4tJWHML9IaH9R0/GBAfzT3TUlfvHq8vpdEs1
	ADNao0IxbIb7XCUpbNesSJ/VtIP73gK84voB7jSech8KziRVzW8U6qWz6250WUC/TWA==
X-Received: by 2002:adf:f584:: with SMTP id f4mr11400420wro.160.1565366447518;
        Fri, 09 Aug 2019 09:00:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyd0h3Wr6J/vLlS9uAENxunoXdKR8emAKimiiX+AY8vQ+GzKk+viVJF8P+EoywgbUTBYR1J
X-Received: by 2002:adf:f584:: with SMTP id f4mr11400253wro.160.1565366445298;
        Fri, 09 Aug 2019 09:00:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366445; cv=none;
        d=google.com; s=arc-20160816;
        b=mNRPabqAoa7wA30fAW1htw952Zkp0fCK94IPeO1MVDCW8BpbFwjJOHQmbIwxN3gHsb
         JlxWssym9w76ricZxlYat6Bvzzh+Epddtecg5CaECLh072aJIvje93sBkM9j4/1xexdy
         jFVpIx497avt9K/ehC2q2P1TkPgHSjRBaDMVHUDYRIcvCTr/75WLcoH8lDCuPdC7E88f
         8AuQ66AA313g3HHn1JzixXxVpjarxWkij/EV9/+S+FUDI4bNKqQ76OczyetqZ1eIYC0W
         hrWbHtMauhh71WtvIlg1xrVYDNhv/itxd7cXnepIGVlvMWKLiqYvGSTEDQF4fo0EFoz5
         swwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=Hgau3dPaYW7ICltIfI18zpDXvENxPnAvUGUSy8Yw3r8=;
        b=RNIQ+4Qv/1hAnys7iS8An03Zzb6ZrpJrzgvA3dlrBB4sMZXzhcoZXzGjEcIQuXdo+Z
         +s5yN0og0WbAGEYQ0jJpzsK8GGLs6kD5MaWqDAUmkUjC265V9OOAdTWfC3FTMzHIi2HZ
         nX6UWoEh+Z0JQVve2eNB7bVZJCYwKeRdFZ7NF1gFvN5vFUumBjUNwJK/O74+1BOqRMS3
         XofEG/s0DXrduZNUAjqbgOCCCZ2CtkkIZO+tdb6OUtbvoV+N3mQfkdlMV0hs6WEbhB1n
         fyPHv+kqSWlUnF8ZxvUew1EF+MDz+aiMF9pn8tBh7pdpOpp49NAgsfx+iyyRmOtKtV2d
         PshQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id l13si4085828wmc.108.2019.08.09.09.00.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:00:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 71177305D3CC;
	Fri,  9 Aug 2019 19:00:44 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id E8585303EF08;
	Fri,  9 Aug 2019 19:00:43 +0300 (EEST)
From: =?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	=?UTF-8?q?Samuel=20Laur=C3=A9n?= <samuel.lauren@iki.fi>,
	Patrick Colp <patrick.colp@oracle.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>, Zhang@kvack.org,
	Yu C <yu.c.zhang@intel.com>,
	=?UTF-8?q?Mihai=20Don=C8=9Bu?= <mdontu@bitdefender.com>,
	=?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v6 00/92] VM introspection
Date: Fri,  9 Aug 2019 18:59:15 +0300
Message-Id: <20190809160047.8319-1-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The KVM introspection subsystem provides a facility for applications running
on the host or in a separate VM, to control the execution of other VM-s
(pause, resume, shutdown), query the state of the vCPUs (GPRs, MSRs etc.),
alter the page access bits in the shadow page tables (only for the hardware
backed ones, eg. Intel's EPT) and receive notifications when events of
interest have taken place (shadow page table level faults, key MSR writes,
hypercalls etc.). Some notifications can be responded to with an action
(like preventing an MSR from being written), others are mere informative
(like breakpoint events which can be used for execution tracing).
With few exceptions, all events are optional. An application using this
subsystem will explicitly register for them.

The use case that gave way for the creation of this subsystem is to monitor
the guest OS and as such the ABI/API is highly influenced by how the guest
software (kernel, applications) sees the world. For example, some events
provide information specific for the host CPU architecture
(eg. MSR_IA32_SYSENTER_EIP) merely because its leveraged by guest software
to implement a critical feature (fast system calls).

At the moment, the target audience for KVMI are security software authors
that wish to perform forensics on newly discovered threats (exploits) or
to implement another layer of security like preventing a large set of
kernel rootkits simply by "locking" the kernel image in the shadow page
tables (ie. enforce .text r-x, .rodata rw- etc.). It's the latter case that
made KVMI a separate subsystem, even though many of these features are
available in the device manager (eg. QEMU). The ability to build a security
application that does not interfere (in terms of performance) with the
guest software asks for a specialized interface that is designed for minimum
overhead.

This patch series is based on 5.0-rc7,
commit de3ccd26fafc ("KVM: MMU: record maximum physical address width in kvm_mmu_extended_role").

The previous RFC (v5) can be read here:

	https://www.spinics.net/lists/kvm/msg179441.html

Thanks to Samuel Laurén and Mathieu Tarral, the previous version has
been integrated and tested with libVMI.

	KVM-VMI: https://github.com/KVM-VMI/kvm-vmi
	Kernel:  https://github.com/KVM-VMI/kvm/tree/kvmi
	QEMU:    https://github.com/KVM-VMI/qemu/tree/kvmi
	         (not all patches, but enough to work)
	libVMI:  https://github.com/KVM-VMI/libvmi/tree/kvmi

Thanks to Weijiang Yang, the previous version has been integrated and
tested with the SPP patch series.

	https://github.com/adlazar/kvm/tree/kvmi-v5-spp

Quickstart:

	https://github.com/adlazar/kvm/blob/kvmi-v5-spp/tools/kvm/kvmi/README

I hope this version will be merged into KVM-VMI project too.

Patches 1-20: unroll a big part of the KVM introspection subsystem,
sent in one patch in the previous versions.

Patches 21-24: extend the current page tracking code.

Patches 25-33: make use of page tracking to support the
KVMI_SET_PAGE_ACCESS introspection command and the KVMI_EVENT_PF event
(on EPT violations caused by the tracking settings).

Patches 34-42: include the SPP feature (Enable Sub-page
Write Protection Support), already sent to KVM list:

	https://lore.kernel.org/lkml/20190717133751.12910-1-weijiang.yang@intel.com/

Patches 43-46: add the commands needed to use SPP.

Patches 47-63: unroll almost all the rest of the introspection code.

Patches 64-67: add single-stepping, mostly as a way to overcome the
unimplemented instructions, but also as a feature for the introspection
tool.

Patches 68-70: cover more cases related to EPT violations.

Patches 71-73: add the remote mapping feature, allowing the introspection
tool to map into its address space a page from guest memory.

Patches 74: add a fix to hypercall emulation.

Patches 75-76: disable some features/optimizations when the introspection
code is present.

Patches 77-78: add trace functions for the introspection code and change
some related to interrupts/exceptions injection.

Patches 79-92: new instruction for the x86 emulator, including cmpxchg
fixes.

To do:

  - run stress tests with SPP enabled
  - add introspection support for alternate EPT views (almost done)
  - add introspection support for virtualization exceptions #VE (almost done)
  - add KVM tests

Changes since v5:

  - small changes to the protocol, but enough to make it backward
    incompatible with v5
  - fix CR3 interception (thanks to Mathieu Tarral for reporting the issue)
  - add SPP support (thanks to Weijiang Yang)
  - add two more ioctls in order to let userspace/QEMU control
    the commands/events allowed for introspection
  - extend the breakpoint event with the instruction length
  - complete the descriptor table registers interception
  - add new instructions to the x86 emulator
  - move arch dependent code to arch/x86/kvm/
  - lots of fixes, especially on page tracking, single-stepping, exception
    injection and remote memory mapping
  - the guests are much more stable (on pair with our introspection
    products using Xen)
  - speed improvements (the penalty on web browsing actions is 50% lower,
    at least)


Adalbert Lazăr (25):
  kvm: introspection: add basic ioctls (hook/unhook)
  kvm: introspection: add permission access ioctls
  kvm: introspection: add the read/dispatch message function
  kvm: introspection: add KVMI_GET_VERSION
  kvm: introspection: add KVMI_CONTROL_CMD_RESPONSE
  kvm: introspection: honor the reply option when handling the
    KVMI_GET_VERSION command
  kvm: introspection: add KVMI_CHECK_COMMAND and KVMI_CHECK_EVENT
  kvm: introspection: add KVMI_CONTROL_VM_EVENTS
  kvm: introspection: add a jobs list to every introspected vCPU
  kvm: introspection: make the vCPU wait even when its jobs list is
    empty
  kvm: introspection: add KVMI_EVENT_UNHOOK
  kvm: x86: intercept the write access on sidt and other emulated
    instructions
  kvm: introspection: add KVMI_CONTROL_SPP
  kvm: introspection: extend the internal database of tracked pages with
    write_bitmap info
  kvm: introspection: add KVMI_GET_PAGE_WRITE_BITMAP
  kvm: introspection: add KVMI_SET_PAGE_WRITE_BITMAP
  kvm: add kvm_vcpu_kick_and_wait()
  kvm: introspection: add KVMI_PAUSE_VCPU and KVMI_EVENT_PAUSE_VCPU
  kvm: x86: add kvm_arch_vcpu_set_guest_debug()
  kvm: introspection: add custom input when single-stepping a vCPU
  kvm: x86: keep the page protected if tracked by the introspection tool
  kvm: x86: filter out access rights only when tracked by the
    introspection tool
  kvm: x86: disable gpa_available optimization in
    emulator_read_write_onepage()
  kvm: x86: disable EPT A/D bits if introspection is present
  kvm: introspection: add trace functions

Marian Rotariu (1):
  kvm: introspection: add KVMI_GET_CPUID

Mihai Donțu (47):
  kvm: introduce KVMI (VM introspection subsystem)
  kvm: introspection: add KVMI_GET_GUEST_INFO
  kvm: introspection: handle introspection commands before returning to
    guest
  kvm: introspection: handle vCPU related introspection commands
  kvm: introspection: handle events and event replies
  kvm: introspection: introduce event actions
  kvm: introspection: add KVMI_GET_VCPU_INFO
  kvm: page track: add track_create_slot() callback
  kvm: x86: provide all page tracking hooks with the guest virtual
    address
  kvm: page track: add support for preread, prewrite and preexec
  kvm: x86: wire in the preread/prewrite/preexec page trackers
  kvm: x86: add kvm_mmu_nested_pagefault()
  kvm: introspection: use page track
  kvm: x86: consult the page tracking from kvm_mmu_get_page() and
    __direct_map()
  kvm: introspection: add KVMI_CONTROL_EVENTS
  kvm: x86: add kvm_spt_fault()
  kvm: introspection: add KVMI_EVENT_PF
  kvm: introspection: add KVMI_GET_PAGE_ACCESS
  kvm: introspection: add KVMI_SET_PAGE_ACCESS
  kvm: introspection: add KVMI_READ_PHYSICAL and KVMI_WRITE_PHYSICAL
  kvm: introspection: add KVMI_GET_REGISTERS
  kvm: introspection: add KVMI_SET_REGISTERS
  kvm: introspection: add KVMI_INJECT_EXCEPTION + KVMI_EVENT_TRAP
  kvm: introspection: add KVMI_CONTROL_CR and KVMI_EVENT_CR
  kvm: introspection: add KVMI_CONTROL_MSR and KVMI_EVENT_MSR
  kvm: introspection: add KVMI_GET_XSAVE
  kvm: introspection: add KVMI_GET_MTRR_TYPE
  kvm: introspection: add KVMI_EVENT_XSETBV
  kvm: introspection: add KVMI_EVENT_BREAKPOINT
  kvm: introspection: add KVMI_EVENT_HYPERCALL
  kvm: introspection: use single stepping on unimplemented instructions
  kvm: x86: emulate a guest page table walk on SPT violations due to A/D
    bit updates
  kvm: x86: do not unconditionally patch the hypercall instruction
    during emulation
  kvm: x86: emulate movsd xmm, m64
  kvm: x86: emulate movss xmm, m32
  kvm: x86: emulate movq xmm, m64
  kvm: x86: emulate movq r, xmm
  kvm: x86: emulate movd xmm, m32
  kvm: x86: enable the half part of movss, movsd, movups
  kvm: x86: emulate lfence
  kvm: x86: emulate xorpd xmm2/m128, xmm1
  kvm: x86: emulate xorps xmm/m128, xmm
  kvm: x86: emulate fst/fstp m64fp
  kvm: x86: make lock cmpxchg r, r/m atomic
  kvm: x86: emulate lock cmpxchg8b atomically
  kvm: x86: emulate lock cmpxchg16b m128
  kvm: x86: fallback to the single-step on multipage CMPXCHG emulation

Mircea Cîrjaliu (5):
  kvm: introspection: add vCPU related data
  kvm: introspection: add KVMI_EVENT_CREATE_VCPU
  mm: add support for remote mapping
  kvm: introspection: add memory map/unmap support on the guest side
  kvm: introspection: use remote mapping

Nicușor Cîțu (5):
  kvm: x86: block any attempt to disable MSR interception if tracked by
    introspection
  kvm: introspection: add KVMI_EVENT_DESCRIPTOR
  kvm: introspection: add single-stepping
  kvm: introspection: add KVMI_EVENT_SINGLESTEP
  kvm: x86: add tracepoints for interrupt and exception injections

Yang Weijiang (9):
  Documentation: Introduce EPT based Subpage Protection
  KVM: VMX: Add control flags for SPP enabling
  KVM: VMX: Implement functions for SPPT paging setup
  KVM: VMX: Introduce SPP access bitmap and operation functions
  KVM: VMX: Add init/set/get functions for SPP
  KVM: VMX: Introduce SPP user-space IOCTLs
  KVM: VMX: Handle SPP induced vmexit and page fault
  KVM: MMU: Enable Lazy mode SPPT setup
  KVM: MMU: Handle host memory remapping and reclaim

 Documentation/virtual/kvm/api.txt        |  104 ++
 Documentation/virtual/kvm/hypercalls.txt |   68 +-
 Documentation/virtual/kvm/kvmi.rst       | 1640 +++++++++++++++++
 Documentation/virtual/kvm/spp_kvm.txt    |  173 ++
 arch/x86/Kconfig                         |    9 +
 arch/x86/include/asm/cpufeatures.h       |    1 +
 arch/x86/include/asm/kvm_emulate.h       |    3 +-
 arch/x86/include/asm/kvm_host.h          |   52 +-
 arch/x86/include/asm/kvm_page_track.h    |   33 +-
 arch/x86/include/asm/kvmi_guest.h        |   10 +
 arch/x86/include/asm/kvmi_host.h         |   51 +
 arch/x86/include/asm/vmx.h               |   12 +
 arch/x86/include/uapi/asm/kvmi.h         |  124 ++
 arch/x86/include/uapi/asm/vmx.h          |    2 +
 arch/x86/kernel/Makefile                 |    1 +
 arch/x86/kernel/cpu/intel.c              |    4 +
 arch/x86/kernel/kvmi_mem_guest.c         |   26 +
 arch/x86/kvm/Kconfig                     |    7 +
 arch/x86/kvm/Makefile                    |    1 +
 arch/x86/kvm/emulate.c                   |  315 +++-
 arch/x86/kvm/kvmi.c                      | 1141 ++++++++++++
 arch/x86/kvm/mmu.c                       |  645 ++++++-
 arch/x86/kvm/mmu.h                       |    5 +
 arch/x86/kvm/page_track.c                |  147 +-
 arch/x86/kvm/svm.c                       |  168 +-
 arch/x86/kvm/trace.h                     |  118 +-
 arch/x86/kvm/vmx/capabilities.h          |    5 +
 arch/x86/kvm/vmx/vmx.c                   |  347 +++-
 arch/x86/kvm/vmx/vmx.h                   |    2 +
 arch/x86/kvm/x86.c                       |  601 ++++++-
 drivers/gpu/drm/i915/gvt/kvmgt.c         |    2 +-
 include/linux/kvm_host.h                 |   26 +
 include/linux/kvmi.h                     |   68 +
 include/linux/page-flags.h               |    9 +-
 include/linux/remote_mapping.h           |  167 ++
 include/linux/swait.h                    |   11 +
 include/trace/events/kvmi.h              |  680 +++++++
 include/uapi/linux/kvm.h                 |   34 +
 include/uapi/linux/kvm_para.h            |   10 +-
 include/uapi/linux/kvmi.h                |  286 +++
 include/uapi/linux/remote_mapping.h      |   18 +
 kernel/signal.c                          |    1 +
 mm/Kconfig                               |    8 +
 mm/Makefile                              |    1 +
 mm/memory-failure.c                      |   69 +-
 mm/migrate.c                             |    9 +-
 mm/remote_mapping.c                      | 1834 +++++++++++++++++++
 mm/rmap.c                                |   13 +-
 mm/vmscan.c                              |    3 +-
 virt/kvm/kvm_main.c                      |   70 +-
 virt/kvm/kvmi.c                          | 2054 ++++++++++++++++++++++
 virt/kvm/kvmi_int.h                      |  311 ++++
 virt/kvm/kvmi_mem.c                      |  324 ++++
 virt/kvm/kvmi_mem_guest.c                |  651 +++++++
 virt/kvm/kvmi_msg.c                      | 1236 +++++++++++++
 55 files changed, 13485 insertions(+), 225 deletions(-)
 create mode 100644 Documentation/virtual/kvm/kvmi.rst
 create mode 100644 Documentation/virtual/kvm/spp_kvm.txt
 create mode 100644 arch/x86/include/asm/kvmi_guest.h
 create mode 100644 arch/x86/include/asm/kvmi_host.h
 create mode 100644 arch/x86/include/uapi/asm/kvmi.h
 create mode 100644 arch/x86/kernel/kvmi_mem_guest.c
 create mode 100644 arch/x86/kvm/kvmi.c
 create mode 100644 include/linux/kvmi.h
 create mode 100644 include/linux/remote_mapping.h
 create mode 100644 include/trace/events/kvmi.h
 create mode 100644 include/uapi/linux/kvmi.h
 create mode 100644 include/uapi/linux/remote_mapping.h
 create mode 100644 mm/remote_mapping.c
 create mode 100644 virt/kvm/kvmi.c
 create mode 100644 virt/kvm/kvmi_int.h
 create mode 100644 virt/kvm/kvmi_mem.c
 create mode 100644 virt/kvm/kvmi_mem_guest.c
 create mode 100644 virt/kvm/kvmi_msg.c

