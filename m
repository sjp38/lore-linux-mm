Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 373538E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 08:56:29 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 68so12705103pfr.6
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 05:56:29 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 15si12209513pgv.351.2018.12.11.05.56.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 05:56:28 -0800 (PST)
Date: Tue, 11 Dec 2018 07:56:26 -0600
From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [PATCH] PCI/P2PDMA: Match interface changes to
 devm_memremap_pages()
Message-ID: <20181211135626.GC99796@google.com>
References: <20181130225911.2900-1-logang@deltatee.com>
 <20181206204643.GC247703@google.com>
 <c226426d-e88c-da18-f643-f3faaf1c0dbd@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c226426d-e88c-da18-f643-f3faaf1c0dbd@deltatee.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-pci@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>

On Thu, Dec 06, 2018 at 03:17:00PM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2018-12-06 1:46 p.m., Bjorn Helgaas wrote:
> > On Fri, Nov 30, 2018 at 03:59:11PM -0700, Logan Gunthorpe wrote:
> >> "mm-hmm-mark-hmm_devmem_add-add_resource-export_symbol_gpl.patch" in the
> >> mm tree breaks p2pdma. The patch was written and reviewed before p2pdma
> >> was merged so the necessary changes were not done to the call site in
> >> that code.
> >>
> >> Without this patch, all drivers will fail to register P2P resources
> >> because devm_memremap_pages() will return -EINVAL due to the 'kill'
> >> member of the pagemap structure not yet being set.
> >>
> >> Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
> >> Cc: Andrew Morton <akpm@linux-foundation.org>
> >> Cc: Dan Williams <dan.j.williams@intel.com>
> >> Cc: Bjorn Helgaas <bhelgaas@google.com>
> > 
> > Applied with Dan's reviewed-by to pci/peer-to-peer for v4.21, thanks!
> > 
> > If the mm patch you mention gets merged for v4.20, let me know and I can
> > promote this to for-linus so v4.20 doesn't end up broken.
> 
> Thanks Bjorn, but I think Andrew has also picked it up in the mm tree
> with the patch in question. My hope is that he squashes the two but I'm
> not sure what his intentions are. I mostly copied you for  information
> purposes as this patch shouldn't even compile without Dan's patch.
> 
> Though, I guess we'll find out what goes in after the merge window --
> you may not need to do anything.

OK, I dropped this because I don't have the matching mm patch.  I agree,
it should be squashed so we avoid a bisection hole.  Let me know if I
need to do anything else with this.

Bjorn
