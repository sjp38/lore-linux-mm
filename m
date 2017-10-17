Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E0F856B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 03:41:05 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q83so1049733qke.16
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 00:41:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s5si66247qkb.412.2017.10.17.00.41.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Oct 2017 00:41:05 -0700 (PDT)
Date: Tue, 17 Oct 2017 03:40:56 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <1441791227.21027037.1508226056893.JavaMail.zimbra@redhat.com>
In-Reply-To: <20171017071633.GA9207@infradead.org>
References: <20171012155027.3277-1-pagupta@redhat.com> <20171012155027.3277-3-pagupta@redhat.com> <20171017071633.GA9207@infradead.org>
Subject: Re: [Qemu-devel] [RFC 2/2] KVM: add virtio-pmem driver
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: kwolf@redhat.com, haozhong zhang <haozhong.zhang@intel.com>, jack@suse.cz, xiaoguangrong eric <xiaoguangrong.eric@gmail.com>, kvm@vger.kernel.org, david@redhat.com, linux-nvdimm@ml01.01.org, ross zwisler <ross.zwisler@intel.com>, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, linux-mm@kvack.org, stefanha@redhat.com, pbonzini@redhat.com, dan j williams <dan.j.williams@intel.com>, nilal@redhat.com


> 
> I think this driver is at entirely the wrong level.
> 
> If you want to expose pmem to a guest with flushing assist do it
> as pmem, and not a block driver.

Are you saying do it as existing i.e ACPI pmem like interface?
The reason we have created this new driver is exiting pmem driver
does not define proper semantics for guest flushing requests.

Regarding block support of driver, we want to achieve DAX support
to bypass guest page cache. Also, we want to utilize existing DAX
capable file-system interfaces(e.g fsync) from userspace file API's
to trigger the host side flush request.

Below link has details of previous discussion:
https://marc.info/?l=kvm&m=150091133700361&w=2

Thanks,
Pankaj  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
