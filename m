Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id B7F5F6B0006
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:26:41 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id n87so2694979vsi.13
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 06:26:41 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id o123sor3772119vso.14.2018.10.31.06.26.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 06:26:40 -0700 (PDT)
Date: Wed, 31 Oct 2018 06:26:30 -0700
Message-Id: <20181031132634.50440-1-marcorr@google.com>
Mime-Version: 1.0
Subject: [kvm PATCH v5 0/4] shrink vcpu_vmx down to order 2
From: Marc Orr <marcorr@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, kernellwp@gmail.com
Cc: Marc Orr <marcorr@google.com>

Compared to the last version of these patches, I've acted on Dave
Hansen's suggestions to get rid of redundant fpu storage and move it out
of the kvm_vcpu_arch struct.

For now, I've left the vmalloc patches in the series, but we might end
up dropping them. Thus, I've have not responded to Sean Christopherson's
review on those patches yet.

Marc Orr (4):
  kvm: x86: Use task structs fpu field for user
  kvm: x86: Dynamically allocate guest_fpu
  kvm: vmx: refactor vmx_msrs struct for vmalloc
  kvm: vmx: use vmalloc() to allocate vcpus

 arch/x86/include/asm/kvm_host.h |  10 ++--
 arch/x86/kvm/svm.c              |  10 ++++
 arch/x86/kvm/vmx.c              | 102 +++++++++++++++++++++++++++++---
 arch/x86/kvm/x86.c              |  49 ++++++++++-----
 virt/kvm/kvm_main.c             |  28 +++++----
 5 files changed, 159 insertions(+), 40 deletions(-)

-- 
2.19.1.568.g152ad8e336-goog
