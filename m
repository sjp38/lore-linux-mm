Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3A14F6B027E
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 04:50:39 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 24so3291608qts.2
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 01:50:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m68si1354203qke.366.2017.10.12.01.50.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 01:50:38 -0700 (PDT)
Date: Thu, 12 Oct 2017 09:50:31 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [RFC] KVM "fake DAX" device flushing
Message-ID: <20171012085031.GA1959@stefanha-x1.localdomain>
References: <20171011185146.20295-1-pagupta@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171011185146.20295-1-pagupta@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-nvdimm@ml01.01.org, linux-mm@kvack.org, jack@suse.cz, dan.j.williams@intel.com, riel@redhat.com, haozhong.zhang@intel.com, nilal@redhat.com, kwolf@redhat.com, pbonzini@redhat.com, ross.zwisler@intel.com, david@redhat.com, xiaoguangrong.eric@gmail.com

On Thu, Oct 12, 2017 at 12:21:46AM +0530, Pankaj Gupta wrote:
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

Please post a draft VIRTIO device specification.

The VIRTIO Technical Committee resources and mailing lists are here:

https://www.oasis-open.org/committees/tc_home.php?wg_abbrev=virtio#feedback

Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
