Date: Thu, 23 Jun 2005 14:01:08 +1000
From: Nathan Scott <nathans@sgi.com>
Subject: Re: [PATCH 2.6.12-rc5 2/10] mm: manual page migration-rc3 -- xfs-migrate-page-rc3.patch
Message-ID: <20050623040108.GC711@frodo>
References: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com> <20050622163921.25515.62325.69270@tomahawk.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050622163921.25515.62325.69270@tomahawk.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>, Joel Schopp <jschopp@austin.ibm.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>, Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, lhms-devel@lists.sourceforge.net, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 22, 2005 at 12:30:41 PM -0500, Joel Schopp wrote:
> >However, the routine "xfs_skip_migrate_page()" is added to
> >disallow migration of xfs metadata.
>
> On ppc64 we are aiming to eventually be able to migrate ALL data.  I
> understand we aren't nearly there yet.  I'd like to keep track of what
> we need to do to get there.  What do we need to do to be able to migrate
> xfs metadata?

I guess we'd effectively have to do a fs "freeze" (freeze_bdev)
to prevent new metadata buffers springing into existence, then 
flush out all metadata for the filesystem in question and toss
the associated page cache pages (this is part of the existing
umount behaviour already though).  Then a "thaw" to get the
filesystem to spring back into life.

Its just a Simple Matter Of Programming.  :)

cheers.

-
Nathan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
