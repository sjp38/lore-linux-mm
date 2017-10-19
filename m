Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 077436B0268
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 02:03:22 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 189so6847881iow.8
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 23:03:22 -0700 (PDT)
Received: from quartz.orcorp.ca (quartz.orcorp.ca. [184.70.90.242])
        by mx.google.com with ESMTPS id v1si593788itd.4.2017.10.18.23.03.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 23:03:21 -0700 (PDT)
Date: Thu, 19 Oct 2017 00:02:49 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v9 0/6] MAP_DIRECT for DAX userspace flush
Message-ID: <20171019060249.GA6555@obsidianresearch.com>
References: <20171012142319.GA11254@lst.de>
 <CAPcyv4gTON__Ohop0B5R2gsKXC71bycTBozqGmF3WmwG9C6LVA@mail.gmail.com>
 <20171013065716.GB26461@lst.de>
 <CAPcyv4gaLBBefOU+8f7_ypYnCTjSMk+9nq8NfCqBHAE+NbUusw@mail.gmail.com>
 <20171013163822.GA17411@obsidianresearch.com>
 <CAPcyv4jDHp8z2VgVfyRK1WwMzixYVQnh54LZoPD57HB3yqSPPQ@mail.gmail.com>
 <20171013173145.GA18702@obsidianresearch.com>
 <CAPcyv4jZJRto1jwmNU--pqH_6dOVMyj=68ZwEjAmmkgX=mRk7w@mail.gmail.com>
 <20171014015752.GA25172@obsidianresearch.com>
 <e29eb9ed-2d87-cde8-4efa-50de1fff0c04@grimberg.me>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e29eb9ed-2d87-cde8-4efa-50de1fff0c04@grimberg.me>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sagi Grimberg <sagi@grimberg.me>
Cc: Dan Williams <dan.j.williams@intel.com>, "J. Bruce Fields" <bfields@fieldses.org>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, Linux API <linux-api@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Al Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On Mon, Oct 16, 2017 at 03:02:52PM +0300, Sagi Grimberg wrote:
> But why should the kernel ever need to mangle the CQ? if a lease break
> would deregister the MR the device is expected to generate remote
> protection errors on its own.

The point is to avoid protection errors - hittles change over when the
DAX mapping changes like ODP does.

Theonly way to get there is to notify the app before the mappings
change.. Dan suggested having ibv_pollcq return this indication..

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
