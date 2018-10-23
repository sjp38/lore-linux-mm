Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id AF7076B0010
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 17:13:18 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id t9so2042568wrx.7
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 14:13:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y2-v6sor1850673wru.11.2018.10.23.14.13.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Oct 2018 14:13:17 -0700 (PDT)
MIME-Version: 1.0
References: <20181020211200.255171-1-marcorr@google.com>
In-Reply-To: <20181020211200.255171-1-marcorr@google.com>
From: Marc Orr <marcorr@google.com>
Date: Tue, 23 Oct 2018 17:13:05 -0400
Message-ID: <CAA03e5F9qAB6AyZ=XPcfPapqQOn3rad_PUydZvFjDj3Md9pWEA@mail.gmail.com>
Subject: Re: [kvm PATCH 0/2] kvm: vmalloc vmx vcpus
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org

Adding everyone that's cc'd on [kvm PATCH 1/2] mm: export
__vmalloc_node_range().
Thanks,
MarcOn Sat, Oct 20, 2018 at 5:12 PM Marc Orr <marcorr@google.com> wrote:
>
> Patch series to allocate vmx vcpus with vmalloc() instead of kalloc().
> This enables vendors to pack more VMs on a single host.
>
> Marc Orr (2):
>   mm: export __vmalloc_node_range()
>   kvm: vmx: use vmalloc() to allocate vcpus
>
>  arch/x86/kvm/vmx.c  | 98 +++++++++++++++++++++++++++++++++++++++++----
>  mm/vmalloc.c        |  1 +
>  virt/kvm/kvm_main.c | 28 +++++++------
>  3 files changed, 107 insertions(+), 20 deletions(-)
>
> --
> 2.19.1.568.g152ad8e336-goog
>
