Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id ADB936B0315
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 11:00:42 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id l45so32310041ote.1
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 08:00:42 -0700 (PDT)
Received: from mail-ot0-x241.google.com (mail-ot0-x241.google.com. [2607:f8b0:4003:c0f::241])
        by mx.google.com with ESMTPS id q23si1726945otq.357.2017.06.23.08.00.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 08:00:38 -0700 (PDT)
Received: by mail-ot0-x241.google.com with SMTP id q16so5099772otb.0
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 08:00:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170524172024.30810-1-jglisse@redhat.com>
References: <20170524172024.30810-1-jglisse@redhat.com>
From: Bob Liu <lliubbo@gmail.com>
Date: Fri, 23 Jun 2017 23:00:37 +0800
Message-ID: <CAA_GA1e7LbvY3rZ+FpJ6fLhZ1oUJ_FXVjQvjmS_YSrjZMAv9jw@mail.gmail.com>
Subject: Re: [HMM 00/15] HMM (Heterogeneous Memory Management) v23
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, John Hubbard <jhubbard@nvidia.com>

Hi,

On Thu, May 25, 2017 at 1:20 AM, J=C3=A9r=C3=B4me Glisse <jglisse@redhat.co=
m> wrote:
> Patchset is on top of git://git.cmpxchg.org/linux-mmotm.git so i
> test same kernel as kbuild system, git branch:
>
> https://cgit.freedesktop.org/~glisse/linux/log/?h=3Dhmm-v23
>
> Change since v22 is use of static key for special ZONE_DEVICE case in
> put_page() and build fix for architecture with no mmu.
>
> Everything else is the same. Below is the long description of what HMM
> is about and why. At the end of this email i describe briefly each patch
> and suggest reviewers for each of them.
>
>
> Heterogeneous Memory Management (HMM) (description and justification)
>
> Today device driver expose dedicated memory allocation API through their
> device file, often relying on a combination of IOCTL and mmap calls. The
> device can only access and use memory allocated through this API. This
> effectively split the program address space into object allocated for the
> device and useable by the device and other regular memory (malloc, mmap
> of a file, share memory, =C3=A2) only accessible by CPU (or in a very lim=
ited
> way by a device by pinning memory).
>
> Allowing different isolated component of a program to use a device thus
> require duplication of the input data structure using device memory
> allocator. This is reasonable for simple data structure (array, grid,
> image, =C3=A2) but this get extremely complex with advance data structure
> (list, tree, graph, =C3=A2) that rely on a web of memory pointers. This i=
s
> becoming a serious limitation on the kind of work load that can be
> offloaded to device like GPU.
>
> New industry standard like C++, OpenCL or CUDA are pushing to remove this
> barrier. This require a shared address space between GPU device and CPU s=
o
> that GPU can access any memory of a process (while still obeying memory
> protection like read only). This kind of feature is also appearing in
> various other operating systems.
>
> HMM is a set of helpers to facilitate several aspects of address space
> sharing and device memory management. Unlike existing sharing mechanism

It looks like the address space sharing and device memory management
are two different things. They don't depend on each other and HMM has
helpers for both.

Is it possible to separate these two things into two patchsets?
Which will make it's more easy to review and also follow the "Do one
thing, and do it well" philosophy.

Thanks,
Bob Liu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
