Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 54D136B7C7A
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 17:17:08 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id n25so1761992iog.13
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 14:17:08 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id l64si800391ioa.79.2018.12.06.14.17.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Dec 2018 14:17:04 -0800 (PST)
References: <20181130225911.2900-1-logang@deltatee.com>
 <20181206204643.GC247703@google.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <c226426d-e88c-da18-f643-f3faaf1c0dbd@deltatee.com>
Date: Thu, 6 Dec 2018 15:17:00 -0700
MIME-Version: 1.0
In-Reply-To: <20181206204643.GC247703@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] PCI/P2PDMA: Match interface changes to
 devm_memremap_pages()
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bjorn Helgaas <helgaas@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-pci@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>



On 2018-12-06 1:46 p.m., Bjorn Helgaas wrote:
> On Fri, Nov 30, 2018 at 03:59:11PM -0700, Logan Gunthorpe wrote:
>> "mm-hmm-mark-hmm_devmem_add-add_resource-export_symbol_gpl.patch" in the
>> mm tree breaks p2pdma. The patch was written and reviewed before p2pdma
>> was merged so the necessary changes were not done to the call site in
>> that code.
>>
>> Without this patch, all drivers will fail to register P2P resources
>> because devm_memremap_pages() will return -EINVAL due to the 'kill'
>> member of the pagemap structure not yet being set.
>>
>> Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Dan Williams <dan.j.williams@intel.com>
>> Cc: Bjorn Helgaas <bhelgaas@google.com>
> 
> Applied with Dan's reviewed-by to pci/peer-to-peer for v4.21, thanks!
> 
> If the mm patch you mention gets merged for v4.20, let me know and I can
> promote this to for-linus so v4.20 doesn't end up broken.

Thanks Bjorn, but I think Andrew has also picked it up in the mm tree
with the patch in question. My hope is that he squashes the two but I'm
not sure what his intentions are. I mostly copied you for  information
purposes as this patch shouldn't even compile without Dan's patch.

Though, I guess we'll find out what goes in after the merge window --
you may not need to do anything.

Logan
