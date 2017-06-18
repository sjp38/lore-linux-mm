Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0DD2E6B0313
	for <linux-mm@kvack.org>; Sun, 18 Jun 2017 04:18:52 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id r103so2400936wrb.0
        for <linux-mm@kvack.org>; Sun, 18 Jun 2017 01:18:52 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id o21si6742546wro.277.2017.06.18.01.18.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Jun 2017 01:18:50 -0700 (PDT)
Date: Sun, 18 Jun 2017 10:18:50 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
	byte-addressable updates to pmem
Message-ID: <20170618081850.GA26332@lst.de>
References: <149766212410.22552.15957843500156182524.stgit@dwillia2-desk3.amr.corp.intel.com> <149766213493.22552.4057048843646200083.stgit@dwillia2-desk3.amr.corp.intel.com> <CALCETrU1Hg=q4cdQDex--3nVBfwRC1o=9pC6Ss77Z8Lxg7ZJLg@mail.gmail.com> <CAPcyv4j4UEegViDJcLZjVv5AFGC18-DcvHFnhZatB0hH3BY85g@mail.gmail.com> <CALCETrUfv26pvmyQ1gOkKbzfSXK2DnmeBG6VmSWjFy1WBhknTw@mail.gmail.com> <CAPcyv4iPb69e+rE3fJUzm9U_P_dLfhantU9mvYmV-R0oQee4rA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iPb69e+rE3fJUzm9U_P_dLfhantU9mvYmV-R0oQee4rA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

On Sat, Jun 17, 2017 at 08:15:05PM -0700, Dan Williams wrote:
> The hang up is that it requires per-fs enabling as it needs to be
> careful to manage mmap_sem vs fs journal locks for example. I know the
> in-development NOVA [1] filesystem is planning to support this out of
> the gate. ext4 would be open to implementing it, but I think xfs is
> cold on the idea. Christoph originally proposed it here [2], before
> Dave went on to propose immutable semantics.
> 
> [1]: https://github.com/NVSL/NOVA
> [2]: https://lists.01.org/pipermail/linux-nvdimm/2016-February/004609.html

And I stand to that statement.  Let's get DAX stable first, and
properly cleaned up (e.g. follow on work with separating it entirely
from the block device).  Then think hard about how most of the 
persistent memory technologies actually work, including the point that
for a lot of workloads page cache will be required at least on the
write side.   And then come up with actual real use cases and we can
look into it.

And stop trying to shoe-horn crap like this in.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
