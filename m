Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3B9606B0003
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 19:49:35 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id r75-v6so7693185vkr.1
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 16:49:35 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id z72sor15496357vsc.113.2018.10.31.16.49.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 16:49:34 -0700 (PDT)
Date: Wed, 31 Oct 2018 16:49:26 -0700
Message-Id: <20181031234928.144206-1-marcorr@google.com>
Mime-Version: 1.0
Subject: [kvm PATCH v6 0/2] shrink vcpu_vmx down to order 2
From: Marc Orr <marcorr@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, kernellwp@gmail.com
Cc: Marc Orr <marcorr@google.com>

Compared to the last version, I've:
(1) dropped the vmalloc patches
(2) updated the kmem cache for the guest_fpu field in the kvm_vcpu_arch
    struct to be sized according to fpu_kernel_xstate_size
(3) Added minimum FPU checks in KVM's x86 init logic to avoid memory
    corruption issues.

Marc Orr (2):
  kvm: x86: Use task structs fpu field for user
  kvm: x86: Dynamically allocate guest_fpu

 arch/x86/include/asm/kvm_host.h | 10 +++---
 arch/x86/kvm/svm.c              | 10 ++++++
 arch/x86/kvm/vmx.c              | 10 ++++++
 arch/x86/kvm/x86.c              | 55 ++++++++++++++++++++++++---------
 4 files changed, 65 insertions(+), 20 deletions(-)

-- 
2.19.1.568.g152ad8e336-goog
