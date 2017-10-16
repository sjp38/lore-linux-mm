Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 101AB6B0033
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 03:22:30 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id q18so8317308wmg.18
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 00:22:30 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id i96si5715916wri.295.2017.10.16.00.22.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 00:22:28 -0700 (PDT)
Date: Mon, 16 Oct 2017 09:22:27 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v9 0/6] MAP_DIRECT for DAX userspace flush
Message-ID: <20171016072227.GA28270@lst.de>
References: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com> <20171012142319.GA11254@lst.de> <CAPcyv4gTON__Ohop0B5R2gsKXC71bycTBozqGmF3WmwG9C6LVA@mail.gmail.com> <20171013065716.GB26461@lst.de> <CAPcyv4gaLBBefOU+8f7_ypYnCTjSMk+9nq8NfCqBHAE+NbUusw@mail.gmail.com> <20171013163822.GA17411@obsidianresearch.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171013163822.GA17411@obsidianresearch.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, Linux API <linux-api@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, "J. Bruce Fields" <bfields@fieldses.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jeff Layton <jlayton@poochiereds.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Oct 13, 2017 at 10:38:22AM -0600, Jason Gunthorpe wrote:
> > scheme specific to RDMA which seems like a waste to me when we can
> > generically signal an event on the fd for any event that effects any
> > of the vma's on the file. The FL_LAYOUT lease impacts the entire file,
> > so as far as I can see delaying the notification until MR-init is too
> > late, too granular, and too RDMA specific.
> 
> But for RDMA a FD is not what we care about - we want the MR handle so
> the app knows which MR needs fixing.

Yes.  Although the fd for the ibX device might be a good handle to
transport that information, unlike the fd for the mapped file.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
