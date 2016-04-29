Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id DF0B36B007E
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 12:48:30 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id dx6so178445341pad.0
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 09:48:30 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id 144si17219108pfx.223.2016.04.29.09.48.30
        for <linux-mm@kvack.org>;
        Fri, 29 Apr 2016 09:48:30 -0700 (PDT)
Date: Fri, 29 Apr 2016 10:48:28 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 06/18] dax: Remove dead zeroing code from fault handlers
Message-ID: <20160429164828.GB5888@linux.intel.com>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <1461015341-20153-7-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461015341-20153-7-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Mon, Apr 18, 2016 at 11:35:29PM +0200, Jan Kara wrote:
> Now that all filesystems zero out blocks allocated for a fault handler,
> we can just remove the zeroing from the handler itself. Also add checks
> that no filesystem returns to us unwritten or new buffer.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
