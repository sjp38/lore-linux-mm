Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 25D366B0069
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 11:29:43 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id p17so7081577uap.12
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 08:29:43 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x7sor2009000vkg.275.2018.01.17.08.29.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jan 2018 08:29:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180116210321.GB8801@redhat.com>
References: <20180116210321.GB8801@redhat.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 17 Jan 2018 21:59:40 +0530
Message-ID: <CAKTCnznQ95Ao5hOEH=pecaoU9G9xYvitV64shf8S39vzfH+uyA@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] CAPI/CCIX cache coherent device memory (NUMA too ?)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: lsf-pc <lsf-pc@lists.linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <jhubbard@nvidia.com>, Jonathan Masters <jcm@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Wed, Jan 17, 2018 at 2:33 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> CAPI (on IBM Power8 and 9) and CCIX are two new standard that
> build on top of existing interconnect (like PCIE) and add the
> possibility for cache coherent access both way (from CPU to
> device memory and from device to main memory). This extend
> what we are use to with PCIE (where only device to main memory
> can be cache coherent but not CPU to device memory).
>
> How is this memory gonna be expose to the kernel and how the
> kernel gonna expose this to user space is the topic i want to
> discuss. I believe this is highly device specific for instance
> for GPU you want the device memory allocation and usage to be
> under the control of the GPU device driver. Maybe other type
> of device want different strategy.
>
> The HMAT patchset is partialy related to all this as it is about
> exposing different type of memory available in a system for CPU
> (HBM, main memory, ...) and some of their properties (bandwidth,
> latency, ...).
>
>
> We can start by looking at how CAPI and CCIX plan to expose this
> to the kernel and try to list some of the type of devices we
> expect to see. Discussion can then happen on how to represent this
> internaly to the kernel and how to expose this to userspace.
>
> Note this might also trigger discussion on a NUMA like model or
> on extending/replacing it by something more generic.
>

Yes, I agree. I've had some experience with both NUMA and HMM/CDM
models. I think we should compare and contrast the trade-offs
and also discuss how we want to expose some of the ZONE_DEVICE
information back to user space.

>
> Peoples (alphabetical order on first name) sorry if i missed
> anyone:
>     "Anshuman Khandual" <khandual@linux.vnet.ibm.com>
>     "Balbir Singh" <bsingharora@gmail.com>
>     "Dan Williams" <dan.j.williams@intel.com>
>     "John Hubbard" <jhubbard@nvidia.com>
>     "Jonathan Masters" <jcm@redhat.com>
>     "Ross Zwisler" <ross.zwisler@linux.intel.com>

I'd love to be there if invited.

Thanks,
Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
