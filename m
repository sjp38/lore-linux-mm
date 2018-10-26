Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 69B7B6B02D3
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 03:59:07 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id v88-v6so163637pfk.19
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 00:59:07 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id k128-v6sor6794697pfc.4.2018.10.26.00.59.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Oct 2018 00:59:06 -0700 (PDT)
Date: Fri, 26 Oct 2018 00:58:58 -0700
Message-Id: <20181026075900.111462-1-marcorr@google.com>
Mime-Version: 1.0
Subject: [kvm PATCH v4 0/2] use vmalloc to allocate vmx vcpus
From: Marc Orr <marcorr@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com
Cc: Marc Orr <marcorr@google.com>

A couple of patches to allocate vmx vcpus with vmalloc instead of
kalloc, which enables vcpu allocation to succeeed when contiguous
physical memory is sparse.

Compared to the last version of these patches, this version:
1. Splits out the refactoring of the vmx_msrs struct into it's own
patch, as suggested by Sean Christopherson <sean.j.christopherson@intel.com>.
2. Leverages the __vmalloc() API rather than introducing a new vzalloc()
API, as suggested by Michal Hocko <mhocko@kernel.org>.

Marc Orr (2):
  kvm: vmx: refactor vmx_msrs struct for vmalloc
  kvm: vmx: use vmalloc() to allocate vcpus

 arch/x86/kvm/vmx.c  | 92 +++++++++++++++++++++++++++++++++++++++++----
 virt/kvm/kvm_main.c | 28 ++++++++------
 2 files changed, 100 insertions(+), 20 deletions(-)

-- 
2.19.1.568.g152ad8e336-goog
