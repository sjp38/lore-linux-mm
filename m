Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD176B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 15:22:43 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id t134so2010819oih.6
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 12:22:43 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r26sor4213799ote.331.2017.10.11.12.22.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Oct 2017 12:22:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171011185146.20295-1-pagupta@redhat.com>
References: <20171011185146.20295-1-pagupta@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 11 Oct 2017 12:22:41 -0700
Message-ID: <CAPcyv4iav2gjHR63UfZmzp5u6mZciszarqrn=QXnvf+zjjgEUg@mail.gmail.com>
Subject: Re: [RFC] KVM "fake DAX" device flushing
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KVM list <kvm@vger.kernel.org>, Qemu Developers <qemu-devel@nongnu.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Stefan Hajnoczi <stefanha@redhat.com>, Rik van Riel <riel@redhat.com>, Haozhong Zhang <haozhong.zhang@intel.com>, Nitesh Narayan Lal <nilal@redhat.com>, Kevin Wolf <kwolf@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, "Zwisler, Ross" <ross.zwisler@intel.com>, David Hildenbrand <david@redhat.com>, Xiao Guangrong <xiaoguangrong.eric@gmail.com>

On Wed, Oct 11, 2017 at 11:51 AM, Pankaj Gupta <pagupta@redhat.com> wrote:
> We are sharing the prototype version of 'fake DAX' flushing
> interface for the initial feedback. This is still work in progress
> and not yet ready for merging.
>
> Protoype right now just implements basic functionality without advanced
> features with two major parts:
>
> - Qemu virtio-pmem device
>   It exposes a persistent memory range to KVM guest which at host side is file
>   backed memory and works as persistent memory device. In addition to this it
>   provides a virtio flushing interface for KVM guest to do a Qemu side sync for
>   guest DAX persistent memory range.
>
> - Guest virtio-pmem driver
>   Reads persistent memory range from paravirt device and reserves system memory map.
>   It also allocates a block device corresponding to the pmem range which is accessed
>   by DAX capable file systems. (file system support is still pending).
>
> We shared the project idea for 'fake DAX' flushing interface here [1].
> Based on suggestions here [2], we implemented guest 'virtio-pmem'
> driver and Qemu paravirt device.
>
> [1] https://www.spinics.net/lists/kvm/msg149761.html
> [2] https://www.spinics.net/lists/kvm/msg153095.html
>
> Work yet to be done:
>
> - Separate out the common code used by ACPI pmem interface and
>   reuse it.
>
> - In pmem device memmap allocation and working. There is some parallel work
>   going on upstream related to 'memory_hotplug restructuring' [3] and also hitting
>   a memory section alignment issue [4].
>
>   [3] https://lwn.net/Articles/712099/
>   [4] https://www.mail-archive.com/linux-nvdimm@lists.01.org/msg02978.html
>
> - Provide DAX capable file-system(ext4 & XFS) support.
> - Qemu device flush functionality.
> - Qemu live migration work when host page cache is used.
> - Multiple virtio-pmem disks support.
>
> Prototype implementation for feedback:
>
> Kernel: https://github.com/pagupta/linux/commit/d15cf90074eae91aeed7a228da3faf319566dd40

Please send this as a patch so it can be reviewed over email.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
