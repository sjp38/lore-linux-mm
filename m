Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1FA866B0069
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 06:39:54 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id t54so2488200qte.14
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 03:39:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i39si153719qtb.445.2017.10.12.03.39.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 03:39:53 -0700 (PDT)
Date: Thu, 12 Oct 2017 06:39:48 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <1776453018.19707347.1507804788144.JavaMail.zimbra@redhat.com>
In-Reply-To: <20171012085031.GA1959@stefanha-x1.localdomain>
References: <20171011185146.20295-1-pagupta@redhat.com> <20171012085031.GA1959@stefanha-x1.localdomain>
Subject: Re: [RFC] KVM "fake DAX" device flushing
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Hajnoczi <stefanha@redhat.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-nvdimm@ml01.01.org, linux-mm@kvack.org, jack@suse.cz, dan j williams <dan.j.williams@intel.com>, riel@redhat.com, haozhong zhang <haozhong.zhang@intel.com>, nilal@redhat.com, kwolf@redhat.com, pbonzini@redhat.com, ross zwisler <ross.zwisler@intel.com>, david@redhat.com, xiaoguangrong eric <xiaoguangrong.eric@gmail.com>


> On Thu, Oct 12, 2017 at 12:21:46AM +0530, Pankaj Gupta wrote:
> > We are sharing the prototype version of 'fake DAX' flushing
> > interface for the initial feedback. This is still work in progress
> > and not yet ready for merging.
> > 
> > Protoype right now just implements basic functionality without advanced
> > features with two major parts:
> > 
> > - Qemu virtio-pmem device
> >   It exposes a persistent memory range to KVM guest which at host side is
> >   file
> >   backed memory and works as persistent memory device. In addition to this
> >   it
> >   provides a virtio flushing interface for KVM guest to do a Qemu side sync
> >   for
> >   guest DAX persistent memory range.
> 
> Please post a draft VIRTIO device specification.

Sure! will prepare and share.

Thanks,
Pankaj
 
> 
> The VIRTIO Technical Committee resources and mailing lists are here:
> 
> https://www.oasis-open.org/committees/tc_home.php?wg_abbrev=virtio#feedback
> 
> Stefan
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
