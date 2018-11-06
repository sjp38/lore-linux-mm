Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0AE4D6B04A1
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 17:54:01 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id a199so19898760qkb.23
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 14:54:01 -0800 (PST)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id i64-v6sor15143031qkd.101.2018.11.06.14.54.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Nov 2018 14:54:00 -0800 (PST)
Date: Tue,  6 Nov 2018 14:53:54 -0800
Message-Id: <20181106225356.119901-1-marcorr@google.com>
Mime-Version: 1.0
Subject: [kvm PATCH v8 0/2] shrink vcpu_vmx down to order 2
From: Marc Orr <marcorr@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, kernellwp@gmail.com
Cc: Marc Orr <marcorr@google.com>

Compared to the last version, I've:
(0) Actually update the patches, as explained below.
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
