Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id EFF054402FE
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 18:14:41 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so117432991pad.1
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 15:14:41 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id ks7si19745859pab.9.2015.10.02.15.14.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 15:14:41 -0700 (PDT)
Message-ID: <560F01CD.7060504@deltatee.com>
Date: Fri, 02 Oct 2015 16:14:37 -0600
From: Logan Gunthorpe <logang@deltatee.com>
MIME-Version: 1.0
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>	<20150923044227.36490.99741.stgit@dwillia2-desk3.jf.intel.com>	<20151002212137.GB30448@deltatee.com> <CAPcyv4iwJJX-rSgC0ramLrvccdzDXgnUAUMQbTMpoODo2f7kOw@mail.gmail.com>
In-Reply-To: <CAPcyv4iwJJX-rSgC0ramLrvccdzDXgnUAUMQbTMpoODo2f7kOw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH 14/15] mm, dax, pmem: introduce {get|put}_dev_pagemap()
 for dax-gup
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@sr71.net>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Stephen Bates <Stephen.Bates@pmcs.com>

Hi Dan,

Good to know you've already addressed the struct page issue. We'll watch 
out for an updated patchset to try.


On 02/10/15 03:53 PM, Dan Williams wrote:
> Hmm, I didn't have peer-to-peer PCI-E in mind for this mechanism, but
> the test report is welcome nonetheless.  The definition of dma_addr_t
> is the device view of host memory, not necessarily the device view of
> a peer device's memory range, so I expect you'll run into issues with
> IOMMUs and other parts of the kernel that assume this definition.

Yeah, we've actually been doing this with a number of more "hacky" 
techniques for some time. ZONE_DEVICE just provides us with a much 
cleaner way to set this up that doesn't require patching around 
get_user_pages in various places in the kernel.

We've never had any issues with the IOMMU getting in the way (at least 
on Intel x86). My understanding always was that the IOMMU sits between a 
PCI card and main memory; it doesn't get in the way of peer-to-peer 
transfers. Though admittedly, I don't have a complete understanding of 
how the IOMMU works in the kernel. I'm just speaking from experimental 
experience. We've never actually tried this on other architectures.

Thanks,

Logan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
