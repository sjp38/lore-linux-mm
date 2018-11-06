Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id CA57E6B0497
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 17:20:18 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id i138-v6so11301525ywg.3
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 14:20:18 -0800 (PST)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id y191-v6sor1242519ybe.145.2018.11.06.14.20.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Nov 2018 14:20:17 -0800 (PST)
Date: Tue,  6 Nov 2018 14:20:07 -0800
Message-Id: <20181106222009.90833-1-marcorr@google.com>
Mime-Version: 1.0
Subject: [kvm PATCH v7 0/2] shrink vcpu_vmx down to order 2
From: Marc Orr <marcorr@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, kernellwp@gmail.com
Cc: Marc Orr <marcorr@google.com>

Compared to the last version, I've:
(1) Added a comment to explain the FPU checks in kvm_arch_init()
(2) Changed the kmem_cache_create_usercopy() to kmem_cache_create()

Marc Orr (2):
  kvm: x86: Use task structs fpu field for user
  kvm: x86: Dynamically allocate guest_fpu

 arch/x86/include/asm/kvm_host.h | 10 +++---
 arch/x86/kvm/svm.c              | 10 ++++++
 arch/x86/kvm/vmx.c              | 10 ++++++
 arch/x86/kvm/x86.c              | 55 ++++++++++++++++++++++++---------
 4 files changed, 65 insertions(+), 20 deletions(-)

-- 
2.19.1.930.g4563a0d9d0-goog
