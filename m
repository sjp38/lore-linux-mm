Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 161B06B007E
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 15:00:57 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e190so249986567pfe.3
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 12:00:57 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id 127si17724106pfe.224.2016.04.29.12.00.56
        for <linux-mm@kvack.org>;
        Fri, 29 Apr 2016 12:00:56 -0700 (PDT)
Date: Fri, 29 Apr 2016 13:00:35 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 10/18] dax: Remove pointless writeback from dax_do_io()
Message-ID: <20160429190035.GE5888@linux.intel.com>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <1461015341-20153-11-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461015341-20153-11-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Mon, Apr 18, 2016 at 11:35:33PM +0200, Jan Kara wrote:
> dax_do_io() is calling filemap_write_and_wait() if DIO_LOCKING flags is
> set. Presumably this was copied over from direct IO code. However DAX
> inodes have no pagecache pages to write so the call is pointless. Remove
> it.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
