Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 052826B004D
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 08:14:29 -0400 (EDT)
Date: Wed, 8 Jul 2009 14:22:50 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 4/4] fs: tmpfs, ext2 use new truncate
Message-ID: <20090708122250.GP2714@wotan.suse.de>
References: <20090707144423.GC2714@wotan.suse.de> <20090707144918.GF2714@wotan.suse.de> <20090707163829.GB14947@infradead.org> <20090708065327.GM2714@wotan.suse.de> <20090708111420.GB20924@duck.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090708111420.GB20924@duck.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 08, 2009 at 01:14:20PM +0200, Jan Kara wrote:
> On Wed 08-07-09 08:53:27, Nick Piggin wrote:
> > On Tue, Jul 07, 2009 at 12:38:29PM -0400, Christoph Hellwig wrote:
> > > We can't move this to the caller easily.  ext2_delete_inode gets
> > > called for all inodes, but we only want to go on truncating for the
> > > limited set that passes this check.
> > 
> > Hmm, shouldn't they have no ->i_blocks in that case?
>   Not necessarily. Inode can have extended attributes set and those can
> be stored in a special block which is accounted in i_blocks.

OK fair enough. But I don't know if all those checks are
realy appropriate. For example an IS_APPEND inode should
be able to have its blocks trimmed off if a write fails.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
