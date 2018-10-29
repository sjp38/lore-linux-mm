Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id E5ADA6B0354
	for <linux-mm@kvack.org>; Sun, 28 Oct 2018 21:58:59 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id v2-v6so6101819oie.3
        for <linux-mm@kvack.org>; Sun, 28 Oct 2018 18:58:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t79-v6sor5206886oif.64.2018.10.28.18.58.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 28 Oct 2018 18:58:58 -0700 (PDT)
MIME-Version: 1.0
References: <20181026075900.111462-1-marcorr@google.com>
In-Reply-To: <20181026075900.111462-1-marcorr@google.com>
From: Wanpeng Li <kernellwp@gmail.com>
Date: Mon, 29 Oct 2018 09:58:48 +0800
Message-ID: <CANRm+Cy2K08MCWq0mtqor66Uz8g-MaVKb=JDGD0WostFeogKSA@mail.gmail.com>
Subject: Re: [kvm PATCH v4 0/2] use vmalloc to allocate vmx vcpus
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>
Cc: kvm <kvm@vger.kernel.org>, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>, willy@infradead.org, Sean Christopherson <sean.j.christopherson@intel.com>

On Fri, 26 Oct 2018 at 15:59, Marc Orr <marcorr@google.com> wrote:
>
> A couple of patches to allocate vmx vcpus with vmalloc instead of
> kalloc, which enables vcpu allocation to succeeed when contiguous
> physical memory is sparse.

We have not yet encounter memory is too fragmented to allocate kvm
related metadata in our overcommit pools, is this true requirement
from the product environments?

Regards,
Wanpeng Li

>
> Compared to the last version of these patches, this version:
> 1. Splits out the refactoring of the vmx_msrs struct into it's own
> patch, as suggested by Sean Christopherson <sean.j.christopherson@intel.com>.
> 2. Leverages the __vmalloc() API rather than introducing a new vzalloc()
> API, as suggested by Michal Hocko <mhocko@kernel.org>.
>
> Marc Orr (2):
>   kvm: vmx: refactor vmx_msrs struct for vmalloc
>   kvm: vmx: use vmalloc() to allocate vcpus
>
>  arch/x86/kvm/vmx.c  | 92 +++++++++++++++++++++++++++++++++++++++++----
>  virt/kvm/kvm_main.c | 28 ++++++++------
>  2 files changed, 100 insertions(+), 20 deletions(-)
>
> --
> 2.19.1.568.g152ad8e336-goog
>
