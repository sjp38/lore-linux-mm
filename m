Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id C6E3F6B54C1
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 16:51:40 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id h7so3386364iof.19
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 13:51:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f143sor743471itf.0.2018.11.29.13.51.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 29 Nov 2018 13:51:39 -0800 (PST)
MIME-Version: 1.0
References: <20181106225356.119901-1-marcorr@google.com>
In-Reply-To: <20181106225356.119901-1-marcorr@google.com>
From: Marc Orr <marcorr@google.com>
Date: Thu, 29 Nov 2018 13:51:28 -0800
Message-ID: <CAA03e5Hzu1gVffVRy70BtrGeo4wj25DtYH6Y34N2BZoiSJTviQ@mail.gmail.com>
Subject: Re: [kvm PATCH v8 0/2] shrink vcpu_vmx down to order 2
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, Wanpeng Li <kernellwp@gmail.com>

On Tue, Nov 6, 2018 at 2:53 PM Marc Orr <marcorr@google.com> wrote:
>
> Compared to the last version, I've:
> (0) Actually update the patches, as explained below.
> (1) Added a comment to explain the FPU checks in kvm_arch_init()
> (2) Changed the kmem_cache_create_usercopy() to kmem_cache_create()
>
> Marc Orr (2):
>   kvm: x86: Use task structs fpu field for user
>   kvm: x86: Dynamically allocate guest_fpu
>
>  arch/x86/include/asm/kvm_host.h | 10 +++---
>  arch/x86/kvm/svm.c              | 10 ++++++
>  arch/x86/kvm/vmx.c              | 10 ++++++
>  arch/x86/kvm/x86.c              | 55 ++++++++++++++++++++++++---------
>  4 files changed, 65 insertions(+), 20 deletions(-)
>
> --
> 2.19.1.930.g4563a0d9d0-goog
>

Ping.
