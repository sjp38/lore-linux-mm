Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5089C6B0075
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 03:22:55 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id bj1so311085pad.29
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 00:22:55 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id fx15si319067pdb.251.2014.10.17.00.22.54
        for <linux-mm@kvack.org>;
        Fri, 17 Oct 2014 00:22:54 -0700 (PDT)
Date: Thu, 16 Oct 2014 17:52:56 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v11 16/21] vfs,ext2: Remove CONFIG_EXT2_FS_XIP and rename
 CONFIG_FS_XIP to CONFIG_FS_DAX
Message-ID: <20141016215256.GJ11522@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-17-git-send-email-matthew.r.wilcox@intel.com>
 <20141016122618.GN19075@thinkos.etherlink>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141016122618.GN19075@thinkos.etherlink>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Oct 16, 2014 at 02:26:18PM +0200, Mathieu Desnoyers wrote:
> > +	bool "Direct Access support"
> > +	depends on MMU
> > +	help
> > +	  Direct Access (DAX) can be used on memory-backed block devices.
> > +	  If the block device supports DAX and the filesystem supports DAX,
> > +	  then you can avoid using the pagecache to buffer I/Os.  Turning
> > +	  on this option will compile in support for DAX; you will need to
> > +	  mount the filesystem using the -o xip option.
> 
> There is a mismatch between the documentation file (earlier patch): -o
> dax, and this config description: -o xip.

Whoops!  Good catch.

> I guess we might want to switch the mount option to "-o dax" and
> document it as such, and since it should be usable transparently for the
> same use-cases "-o xip" was enabling, we might want to keep parsing of
> "-o xip" in the code for backward compatibility.
> 
> Thoughts ?

That's exactly what we do for ext2.  For ext4, we force people to use
the new -o dax option.  We stop documenting that -o xip exist, and we
print a message to tell people to switch over to -o dax.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
