Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 787806B0005
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 12:30:50 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id dx6so177731268pad.0
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 09:30:50 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id m66si17161131pfm.117.2016.04.29.09.30.49
        for <linux-mm@kvack.org>;
        Fri, 29 Apr 2016 09:30:49 -0700 (PDT)
Date: Fri, 29 Apr 2016 10:30:48 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 05/18] ext2: Avoid DAX zeroing to corrupt data
Message-ID: <20160429163048.GA5888@linux.intel.com>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <1461015341-20153-6-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461015341-20153-6-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Mon, Apr 18, 2016 at 11:35:28PM +0200, Jan Kara wrote:
> Currently ext2 zeroes any data blocks allocated for DAX inode however it
> still returns them as BH_New. Thus DAX code zeroes them again in
> dax_insert_mapping() which can possibly overwrite the data that has been
> already stored to those blocks by a racing dax_io(). Avoid marking
> pre-zeroed buffers as new.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
