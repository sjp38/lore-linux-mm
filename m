Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 20AD56B02B4
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 03:10:10 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id y141so3202599qka.13
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 00:10:10 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id w37si691436qta.296.2017.06.22.00.10.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 00:10:09 -0700 (PDT)
Date: Thu, 22 Jun 2017 00:09:58 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
 byte-addressable updates to pmem
Message-ID: <20170622070958.GG3787@birch.djwong.org>
References: <149766212410.22552.15957843500156182524.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149766213493.22552.4057048843646200083.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170620052214.GA3787@birch.djwong.org>
 <20170620154255.GA2536@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170620154255.GA2536@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, xfs <linux-xfs@vger.kernel.org>

On Tue, Jun 20, 2017 at 09:42:55AM -0600, Ross Zwisler wrote:
> On Mon, Jun 19, 2017 at 10:22:14PM -0700, Darrick J. Wong wrote:
> <>
> > Fourth, the VFS entry points for things like read, write, truncate,
> > utimes, fallocate, etc. all just bail out if S_IOMAP_FROZEN is set on a
> > file, so that the block map cannot be modified.  mmap is still allowed,
> > as we've discussed.  /Maybe/ we can allow fallocate to extend a file
> > with zeroed extents (it will be slow) as I've heard murmurs about
> > wanting to be able to extend a file, maybe not.
> 
> Read and write should still be allowed, right?

<shrug> I had thought the usage model was pretty slanted towards mmap,
but it's not a big deal to turn read/writes into glorified memcpy,
provided we reject the io request if it goes past EOF.

--D

> --
> To unsubscribe from this list: send the line "unsubscribe linux-api" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
