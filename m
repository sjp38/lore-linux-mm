Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 71A306B5B12
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 19:52:56 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id q16so3647592otf.5
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 16:52:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 10sor3617565oth.84.2018.11.30.16.52.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 30 Nov 2018 16:52:55 -0800 (PST)
MIME-Version: 1.0
References: <20181130225911.2900-1-logang@deltatee.com>
In-Reply-To: <20181130225911.2900-1-logang@deltatee.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 30 Nov 2018 16:52:43 -0800
Message-ID: <CAPcyv4jHF-3H09Zgtcm_+AVviMAvE1zfEQnoipAakE+o=KMpUg@mail.gmail.com>
Subject: Re: [PATCH] PCI/P2PDMA: Match interface changes to devm_memremap_pages()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-pci@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Bjorn Helgaas <bhelgaas@google.com>

On Fri, Nov 30, 2018 at 2:59 PM Logan Gunthorpe <logang@deltatee.com> wrote:
>
> "mm-hmm-mark-hmm_devmem_add-add_resource-export_symbol_gpl.patch" in the
> mm tree breaks p2pdma. The patch was written and reviewed before p2pdma
> was merged so the necessary changes were not done to the call site in
> that code.
>
> Without this patch, all drivers will fail to register P2P resources
> because devm_memremap_pages() will return -EINVAL due to the 'kill'
> member of the pagemap structure not yet being set.
>
> Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Dan Williams <dan.j.williams@intel.com>
