Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 196076B0033
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 02:43:04 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id r79so2766770wrb.7
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 23:43:04 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id x5si633373wmx.255.2017.10.26.23.43.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Oct 2017 23:43:02 -0700 (PDT)
Date: Fri, 27 Oct 2017 08:43:01 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 17/17] xfs: support for synchronous DAX faults
Message-ID: <20171027064301.GC22931@lst.de>
References: <20171024152415.22864-1-jack@suse.cz> <20171024152415.22864-18-jack@suse.cz> <20171024222322.GX3666@dastard> <20171026154804.GF31161@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171026154804.GF31161@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>

On Thu, Oct 26, 2017 at 05:48:04PM +0200, Jan Kara wrote:
> But now that I look at XFS implementation again, it misses handling
> of VM_FAULT_NEEDSYNC in xfs_filemap_pfn_mkwrite() (ext4 gets this right).
> I'll fix this by using __xfs_filemap_fault() for xfs_filemap_pfn_mkwrite()
> as well since it mostly duplicates it anyway... Thanks for inquiring!

My first patches move xfs_filemap_pfn_mkwrite to use __xfs_filemap_fault,
but that didn't work.  Wish I'd remember why, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
