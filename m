Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E5E386B0253
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 02:33:15 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id r74so1596173wrb.7
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 23:33:15 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id z80si1194290wmd.264.2017.09.25.23.33.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 23:33:14 -0700 (PDT)
Date: Tue, 26 Sep 2017 08:33:14 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 5/7] xfs: introduce xfs_is_dax_state_changing
Message-ID: <20170926063314.GB6870@lst.de>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com> <20170925231404.32723-6-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170925231404.32723-6-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

> +static bool
> +xfs_is_dax_state_changing(
> +	unsigned int		xflags,
> +	struct xfs_inode	*ip)

And I have no fricking idea what 'is_dax_state_changing' is supposed
to mean for the caller.  This needs a better name and/or a comment
explaining the function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
