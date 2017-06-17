Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9388E6B0311
	for <linux-mm@kvack.org>; Sat, 17 Jun 2017 01:22:14 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 56so9717436wrx.5
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 22:22:14 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id v2si4113334wrv.127.2017.06.16.22.22.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 22:22:13 -0700 (PDT)
Date: Sat, 17 Jun 2017 07:22:12 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [RFC PATCH 1/2] mm: introduce bmap_walk()
Message-ID: <20170617052212.GA8246@lst.de>
References: <149766212410.22552.15957843500156182524.stgit@dwillia2-desk3.amr.corp.intel.com> <149766212976.22552.11210067224152823950.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <149766212976.22552.11210067224152823950.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

On Fri, Jun 16, 2017 at 06:15:29PM -0700, Dan Williams wrote:
> Refactor the core of generic_swapfile_activate() into bmap_walk() so
> that it can be used by a new daxfile_activate() helper (to be added).

No way in hell!  generic_swapfile_activate needs to day and no new users
of ->bmap over my dead body.  It's a guaranteed to fuck up your data left,
right and center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
