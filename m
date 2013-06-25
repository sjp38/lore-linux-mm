Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 123196B0032
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 03:11:50 -0400 (EDT)
Date: Tue, 25 Jun 2013 08:11:40 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v2] vfs: export lseek_execute() to modules
Message-ID: <20130625071139.GZ4165@ZenIV.linux.org.uk>
References: <51C91645.8050502@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51C91645.8050502@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, andi@firstfloor.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Chris.mason@fusionio.com, jbacik@fusionio.com, Ben Myers <bpm@sgi.com>, tytso@mit.edu, hughd@google.com, Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>, sage@inktank.com

On Tue, Jun 25, 2013 at 12:02:13PM +0800, Jeff Liu wrote:
> From: Jie Liu <jeff.liu@oracle.com>
> 
> For those file systems(btrfs/ext4/ocfs2/tmpfs) that support
> SEEK_DATA/SEEK_HOLE functions, we end up handling the similar
> matter in lseek_execute() to update the current file offset
> to the desired offset if it is valid, ceph also does the
> simliar things at ceph_llseek().
> 
> To reduce the duplications, this patch make lseek_execute()
> public accessible so that we can call it directly from the
> underlying file systems.

Umm...  I like it, but it needs changes:
	* inode argument of lseek_execute() is pointless (and killed
off in vfs.git, actually)
	* I'm really not happy about the name of that function.  For
a static it's kinda-sort tolerable, but for something global, let
alone exported...

I've put a modified variant into #for-next; could you check if you are
still OK with it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
