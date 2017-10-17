Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8EC0D6B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 02:46:49 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id y10so428555wmd.4
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 23:46:49 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id r136si6823551wmd.243.2017.10.16.23.46.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 23:46:48 -0700 (PDT)
Date: Tue, 17 Oct 2017 08:46:47 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v9 0/6] MAP_DIRECT for DAX userspace flush
Message-ID: <20171017064647.GA15437@lst.de>
References: <20171012142319.GA11254@lst.de> <CAPcyv4gTON__Ohop0B5R2gsKXC71bycTBozqGmF3WmwG9C6LVA@mail.gmail.com> <20171013065716.GB26461@lst.de> <CAPcyv4gaLBBefOU+8f7_ypYnCTjSMk+9nq8NfCqBHAE+NbUusw@mail.gmail.com> <20171013163822.GA17411@obsidianresearch.com> <CAPcyv4jDHp8z2VgVfyRK1WwMzixYVQnh54LZoPD57HB3yqSPPQ@mail.gmail.com> <20171013173145.GA18702@obsidianresearch.com> <20171016072644.GB28270@lst.de> <CAPcyv4itbYQqVrHBZ=+BRLH39WwDZ_RGg6sSaodVZ93LRYigNA@mail.gmail.com> <CAPcyv4gtnZu7obG7UwaBq1-fwRZj06HCa=mjBfDKKgfp97nYaw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gtnZu7obG7UwaBq1-fwRZj06HCa=mjBfDKKgfp97nYaw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, Linux API <linux-api@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, "J. Bruce Fields" <bfields@fieldses.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jeff Layton <jlayton@poochiereds.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Oct 16, 2017 at 12:44:31PM -0700, Dan Williams wrote:
> > While I agree with the need for a per-MR notification mechanism, one
> > thing we lose by walking away from MAP_DIRECT is a way for a
> > hypervisor to coordinate pass through of a DAX mapping to an RDMA
> > device in a guest. That will remain a case where we will still need to
> > use device-dax. I'm fine if that's the answer, but just want to be
> > clear about all the places we need to protect a DAX mapping against
> > RDMA from a non-ODP device.
> 
> For this specific issue perhaps we promote FL_LAYOUT as a lease-type
> that can be set by fcntl().

I don't think it is a good userspace interface, mostly because it
is about things that don't matter for userspace (block mappings).

It makes sense as a kernel interface for callers that want to pin
down a memory long-term, but for userspace the fact that the block
mapping changes doesn't matter - it matters that their long term
pin is broken by something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
