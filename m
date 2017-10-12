Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B52976B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 10:23:21 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p186so3226692wmd.11
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 07:23:21 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id x6si6572749wrg.476.2017.10.12.07.23.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 07:23:20 -0700 (PDT)
Date: Thu, 12 Oct 2017 16:23:19 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v9 0/6] MAP_DIRECT for DAX userspace flush
Message-ID: <20171012142319.GA11254@lst.de>
References: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

Sorry for chiming in so late, been extremely busy lately.

>From quickly glacing over what the now finally described use case is
(which contradicts the subject btw - it's not about flushing, it's
about not removing block mapping under a MR) and the previous comments
I think that mmap is simply the wrong kind of interface for this.

What we want is support for a new kinds of userspace memory registration in the
RDMA code that uses the pnfs export interface, both getting the block (or
rather byte in this case) mapping, and also gets the FL_LAYOUT lease for the
memory registration.

That btw is exactly what I do for the pNFS RDMA layout, just in-kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
