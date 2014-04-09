Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id BF89C6B0031
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 16:52:24 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id r10so2910530pdi.21
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 13:52:24 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id yl4si968554pbc.470.2014.04.09.13.52.23
        for <linux-mm@kvack.org>;
        Wed, 09 Apr 2014 13:52:23 -0700 (PDT)
Date: Wed, 9 Apr 2014 16:51:11 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v7 07/22] Replace the XIP page fault handler with the DAX
 page fault handler
Message-ID: <20140409205111.GG5727@linux.intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <c2e602f401a580c4fac54b9b8f4a6f8dd0ac1071.1395591795.git.matthew.r.wilcox@intel.com>
 <20140409102758.GM32103@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140409102758.GM32103@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 09, 2014 at 12:27:58PM +0200, Jan Kara wrote:
> > +	if (unlikely(vmf->pgoff >= size)) {
> > +		mutex_unlock(&mapping->i_mmap_mutex);
> > +		goto sigbus;
>   You need to release the block you've got from the filesystem in case of
> error here an below.

What's the API to do that?  Call inode->i_op->setattr()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
