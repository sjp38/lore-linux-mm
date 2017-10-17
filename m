Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 57B386B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 04:30:47 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id q83so1166692qke.16
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 01:30:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u201si2227522qka.61.2017.10.17.01.30.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Oct 2017 01:30:46 -0700 (PDT)
Date: Tue, 17 Oct 2017 04:30:41 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <670833322.21037148.1508229041158.JavaMail.zimbra@redhat.com>
In-Reply-To: <20171017080236.GA27649@infradead.org>
References: <20171012155027.3277-1-pagupta@redhat.com> <20171012155027.3277-3-pagupta@redhat.com> <20171017071633.GA9207@infradead.org> <1441791227.21027037.1508226056893.JavaMail.zimbra@redhat.com> <20171017080236.GA27649@infradead.org>
Subject: Re: [Qemu-devel] [RFC 2/2] KVM: add virtio-pmem driver
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: kwolf@redhat.com, haozhong zhang <haozhong.zhang@intel.com>, jack@suse.cz, xiaoguangrong eric <xiaoguangrong.eric@gmail.com>, kvm@vger.kernel.org, david@redhat.com, linux-nvdimm@ml01.01.org, ross zwisler <ross.zwisler@intel.com>, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, linux-mm@kvack.org, stefanha@redhat.com, pbonzini@redhat.com, dan j williams <dan.j.williams@intel.com>, nilal@redhat.com


> > Are you saying do it as existing i.e ACPI pmem like interface?
> > The reason we have created this new driver is exiting pmem driver
> > does not define proper semantics for guest flushing requests.
> 
> At this point I'm caring about the Linux-internal interface, and
> for that it should be integrated into the nvdimm subsystem and not
> a block driver.  How the host <-> guest interface looks is a different
> idea.
> 
> > 
> > Regarding block support of driver, we want to achieve DAX support
> > to bypass guest page cache. Also, we want to utilize existing DAX
> > capable file-system interfaces(e.g fsync) from userspace file API's
> > to trigger the host side flush request.
> 
> Well, if you want to support XFS+DAX better don't make it a block
> devices, because I'll post patches soon to stop using the block device
> entirely for the DAX case.

o.k I will look at your patches once they are in mailing list.
Thanks for the heads up.

If I am guessing it right, we don't need block device additional features
for pmem? We can bypass block device features like blk device cache flush etc.
Also, still we would be supporting ext4 & XFS filesystem with pmem?

If there is time to your patches can you please elaborate on this a bit.

Thanks,
Pankaj

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
