Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB65B6B007E
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 16:04:04 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 203so222541227pfy.2
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 13:04:04 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id s82si18000677pfj.91.2016.04.29.13.04.03
        for <linux-mm@kvack.org>;
        Fri, 29 Apr 2016 13:04:04 -0700 (PDT)
Date: Fri, 29 Apr 2016 14:03:45 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 14/18] dax: Define DAX lock bit for radix tree
 exceptional entry
Message-ID: <20160429200345.GH5888@linux.intel.com>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <1461015341-20153-15-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461015341-20153-15-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Mon, Apr 18, 2016 at 11:35:37PM +0200, Jan Kara wrote:
> We will use lowest available bit in the radix tree exceptional entry for
> locking of the entry. Define it. Also clean up definitions of DAX entry
> type bits in DAX exceptional entries to use defined constants instead of
> hardcoding numbers and cleanup checking of these bits to not rely on how
> other bits in the entry are set.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
