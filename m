Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 81D036B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 17:27:35 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id a12so3275223qka.7
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 14:27:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b3si1682766qkd.363.2017.10.12.14.27.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 14:27:34 -0700 (PDT)
Date: Thu, 12 Oct 2017 17:27:28 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <1893461099.19940340.1507843648978.JavaMail.zimbra@redhat.com>
In-Reply-To: <CAPcyv4jdWUeoF1PxWhXx3vciLmOL9AyW_yPq0W6DRFe3RP2fkA@mail.gmail.com>
References: <20171012155027.3277-1-pagupta@redhat.com> <20171012155027.3277-2-pagupta@redhat.com> <CAPcyv4jdWUeoF1PxWhXx3vciLmOL9AyW_yPq0W6DRFe3RP2fkA@mail.gmail.com>
Subject: Re: [Qemu-devel] [RFC 1/2] pmem: Move reusable code to base header
 files
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Kevin Wolf <kwolf@redhat.com>, Haozhong Zhang <haozhong.zhang@intel.com>, Jan Kara <jack@suse.cz>, Xiao Guangrong <xiaoguangrong.eric@gmail.com>, KVM list <kvm@vger.kernel.org>, David Hildenbrand <david@redhat.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Ross Zwisler <ross.zwisler@intel.com>, linux-kernel@vger.kernel.org, Qemu Developers <qemu-devel@nongnu.org>, Linux MM <linux-mm@kvack.org>, Stefan Hajnoczi <stefanha@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Nitesh Narayan Lal <nilal@redhat.com>


> 
> On Thu, Oct 12, 2017 at 8:50 AM, Pankaj Gupta <pagupta@redhat.com> wrote:
> >  This patch moves common code to base header files
> >  so that it can be used for both ACPI pmem and VIRTIO pmem
> >  drivers. More common code needs to be moved out in future
> >  based on functionality required for virtio_pmem driver and
> >  coupling of code with existing ACPI pmem driver.
> >
> > Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
> [..]
> > diff --git a/include/linux/pmem_common.h b/include/linux/pmem_common.h
> > new file mode 100644
> > index 000000000000..e2e718c74b3f
> > --- /dev/null
> > +++ b/include/linux/pmem_common.h
> 
> This should be a common C file, not a header.

Sure! will create a common C file to put all the common code there.

> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
