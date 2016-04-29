Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2749B6B007E
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 16:29:28 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id dx6so187275465pad.0
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 13:29:28 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id l5si18077304pfi.243.2016.04.29.13.29.27
        for <linux-mm@kvack.org>;
        Fri, 29 Apr 2016 13:29:27 -0700 (PDT)
Date: Fri, 29 Apr 2016 14:29:26 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 15/18] dax: Allow DAX code to replace exceptional entries
Message-ID: <20160429202926.GI5888@linux.intel.com>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <1461015341-20153-16-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461015341-20153-16-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Mon, Apr 18, 2016 at 11:35:38PM +0200, Jan Kara wrote:
> Currently we forbid page_cache_tree_insert() to replace exceptional radix
> tree entries for DAX inodes. However to make DAX faults race free we will
> lock radix tree entries and when hole is created, we need to replace
> such locked radix tree entry with a hole page. So modify
> page_cache_tree_insert() to allow that.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
