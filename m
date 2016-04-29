Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id BA6216B007E
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 14:56:09 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id zy2so183386636pac.1
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 11:56:09 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id x63si2922960pfb.123.2016.04.29.11.56.08
        for <linux-mm@kvack.org>;
        Fri, 29 Apr 2016 11:56:08 -0700 (PDT)
Date: Fri, 29 Apr 2016 12:56:08 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 09/18] dax: Remove zeroing from dax_io()
Message-ID: <20160429185608.GD5888@linux.intel.com>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <1461015341-20153-10-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461015341-20153-10-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Mon, Apr 18, 2016 at 11:35:32PM +0200, Jan Kara wrote:
> All the filesystems are now zeroing blocks themselves for DAX IO to avoid
> races between dax_io() and dax_fault(). Remove the zeroing code from
> dax_io() and add warning to catch the case when somebody unexpectedly
> returns new or unwritten buffer.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
