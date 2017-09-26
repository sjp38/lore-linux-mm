Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 510526B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 02:32:36 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w12so11542497wrc.2
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 23:32:36 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id w206si924964wmw.256.2017.09.25.23.32.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 23:32:35 -0700 (PDT)
Date: Tue, 26 Sep 2017 08:32:34 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 3/7] xfs: protect S_DAX transitions in XFS read path
Message-ID: <20170926063234.GA6870@lst.de>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com> <20170925231404.32723-4-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170925231404.32723-4-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

We can't just take locking one level up, as we need differnet locking
for different kinds of I/O.

I think you probably want an IOCB_DAX flag to check IS_DAX once and
then stick to it, similar to what we do for direct I/O.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
