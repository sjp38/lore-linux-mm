Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B2246B0279
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 11:57:07 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id t67so174245821ywg.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 08:57:07 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id i3si1105472ywd.282.2016.09.22.08.57.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 08:57:06 -0700 (PDT)
Date: Thu, 22 Sep 2016 11:51:03 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH v2 1/9] ext4: allow DAX writeback for hole punch
Message-ID: <20160922155103.xqxdxum3rq7i4sqa@thunk.org>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
 <20160823220419.11717-2-ross.zwisler@linux.intel.com>
 <20160921152244.GB10516@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160921152244.GB10516@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, Matthew Wilcox <mawilcox@microsoft.com>, stable@vger.kernel.org

On Wed, Sep 21, 2016 at 09:22:44AM -0600, Ross Zwisler wrote:
> 
> Ted & Jan,
> 
> I'm still working on the latest version of the PMD work which integrates with
> the new struct iomap faults.  At this point it doesn't look like I'm going to
> make v4.9, but I think that this bug fix at least should probably go in alone?

Thanks, applied.

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
