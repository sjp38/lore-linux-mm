Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B17176B0069
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 05:57:22 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t25so48652817pfg.3
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 02:57:22 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id he1si1675359pac.124.2016.10.21.02.57.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Oct 2016 02:57:21 -0700 (PDT)
Date: Fri, 21 Oct 2016 02:57:14 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/3] iopmem : A block device for PCIe memory
Message-ID: <20161021095714.GA12209@infradead.org>
References: <1476826937-20665-1-git-send-email-sbates@raithlin.com>
 <CAPcyv4gJ_c-6s2BUjsu6okR1EF53R+KNuXnOc5jv0fuwJaa3cQ@mail.gmail.com>
 <20161019184814.GC16550@cgy1-donard.priv.deltatee.com>
 <20161020232239.GQ23194@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161020232239.GQ23194@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Stephen Bates <sbates@raithlin.com>, Dan Williams <dan.j.williams@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, linux-rdma@vger.kernel.org, linux-block@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, jgunthorpe@obsidianresearch.com, haggaie@mellanox.com, Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@fb.com>, Jonathan Corbet <corbet@lwn.net>, jim.macdonald@everspin.com, sbates@raithin.com, Logan Gunthorpe <logang@deltatee.com>, David Woodhouse <dwmw2@infradead.org>, "Raj, Ashok" <ashok.raj@intel.com>

On Fri, Oct 21, 2016 at 10:22:39AM +1100, Dave Chinner wrote:
> You do realise that local filesystems can silently change the
> location of file data at any point in time, so there is no such
> thing as a "stable mapping" of file data to block device addresses
> in userspace?
> 
> If you want remote access to the blocks owned and controlled by a
> filesystem, then you need to use a filesystem with a remote locking
> mechanism to allow co-ordinated, coherent access to the data in
> those blocks. Anything else is just asking for ongoing, unfixable
> filesystem corruption or data leakage problems (i.e.  security
> issues).

And at least for XFS we have such a mechanism :)  E.g. I have a
prototype of a pNFS layout that uses XFS+DAX to allow clients to do
RDMA directly to XFS files, with the same locking mechanism we use
for the current block and scsi layout in xfs_pnfs.c.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
