Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3FD978E01D1
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 06:25:11 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id f22so4228110qkm.11
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 03:25:11 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z34si2676169qvz.127.2018.12.14.03.25.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 03:25:10 -0800 (PST)
Subject: Re: [kvm PATCH v8 0/2] shrink vcpu_vmx down to order 2
References: <20181106225356.119901-1-marcorr@google.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <8e8140fb-4bd5-f6a1-9434-e6d759007d7f@redhat.com>
Date: Fri, 14 Dec 2018 12:25:01 +0100
MIME-Version: 1.0
In-Reply-To: <20181106225356.119901-1-marcorr@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>, kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, kernellwp@gmail.com

On 06/11/18 23:53, Marc Orr wrote:
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

Queued, thanks.

Paolo
