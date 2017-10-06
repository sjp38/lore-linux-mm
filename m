Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id CF4476B026A
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 18:52:36 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 32so11696390qtp.5
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 15:52:36 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y32sor878674oti.276.2017.10.06.15.52.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Oct 2017 15:52:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1507329939.29211.434.camel@infradead.org>
References: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150732935473.22363.1853399637339625023.stgit@dwillia2-desk3.amr.corp.intel.com>
 <1507329939.29211.434.camel@infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 6 Oct 2017 15:52:34 -0700
Message-ID: <CAPcyv4jLj2WOgPA+B5eYME0uZyuoy3gp35w+4rCa_EZxm-QSKA@mail.gmail.com>
Subject: Re: [PATCH v7 07/12] dma-mapping: introduce dma_has_iommu()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Jan Kara <jack@suse.cz>, Ashok Raj <ashok.raj@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Joerg Roedel <joro@8bytes.org>, Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux API <linux-api@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>

On Fri, Oct 6, 2017 at 3:45 PM, David Woodhouse <dwmw2@infradead.org> wrote:
> On Fri, 2017-10-06 at 15:35 -0700, Dan Williams wrote:
>> Add a helper to determine if the dma mappings set up for a given device
>> are backed by an iommu. In particular, this lets code paths know that a
>> dma_unmap operation will revoke access to memory if the device can not
>> otherwise be quiesced. The need for this knowledge is driven by a need
>> to make RDMA transfers to DAX mappings safe. If the DAX file's block map
>> changes we need to be to reliably stop accesses to blocks that have been
>> freed or re-assigned to a new file.
>
> "a dma_unmap operation revoke access to memory"... but it's OK that the
> next *map* will give the same DMA address to someone else, right?

I'm assuming the next map will be to other physical addresses and a
different requester device since the memory is still registered
exclusively.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
