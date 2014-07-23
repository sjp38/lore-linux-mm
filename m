Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9776B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 09:59:50 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id y10so1681107pdj.21
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 06:59:49 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ef1si2637971pbc.151.2014.07.23.06.59.48
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 06:59:49 -0700 (PDT)
Date: Wed, 23 Jul 2014 09:59:46 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v8 00/22] Support ext4 on NV-DIMMs
Message-ID: <20140723135946.GC6754@linux.intel.com>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
 <20140723123028.GA11355@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140723123028.GA11355@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 23, 2014 at 03:30:28PM +0300, Kirill A. Shutemov wrote:
> On Tue, Jul 22, 2014 at 03:47:48PM -0400, Matthew Wilcox wrote:
> > One of the primary uses for NV-DIMMs is to expose them as a block device
> > and use a filesystem to store files on the NV-DIMM.  While that works,
> > it currently wastes memory and CPU time buffering the files in the page
> > cache.  We have support in ext2 for bypassing the page cache, but it
> > has some races which are unfixable in the current design.  This series
> > of patches rewrite the underlying support, and add support for direct
> > access to ext4.
> 
> Matthew, as discussed before, your patchset make exessive use of
> i_mmap_mutex. Are you going to address this later? Or what's the plan?

Yes, it'll be addressed later.  I have some ideas, but I'd like to get
some experience with just how bad this single mutex is before trying to
split it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
