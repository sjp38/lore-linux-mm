Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.46-mm2 - oops
Date: Sun, 10 Nov 2002 14:17:28 -0500
References: <3DCDD9AC.C3FB30D9@digeo.com> <200211101309.21447.tomlins@cam.org> <3DCEAAE3.C6EE63EF@digeo.com>
In-Reply-To: <3DCEAAE3.C6EE63EF@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200211101417.28440.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Chris Mason <mason@suse.com>
List-ID: <linux-mm.kvack.org>

On November 10, 2002 01:52 pm, Andrew Morton wrote:
> Ed Tomlinson wrote:
> > On November 9, 2002 10:59 pm, Andrew Morton wrote:
> > > Of note in -mm2 is a patch from Chris Mason which teaches reiserfs to
> > > use the mpage code for reads - it should show a nice reduction in CPU
> > > load under reiserfs reads.
> >
> > Booting into mm2 I get:
> >
> > ...
> > Unable to handle kernel NULL pointer dereference at virtual address
> > 00000004
> >
> > ...
> > EIP is at mpage_readpages+0x47/0x140
>
> whoops.  The ->readpages API was changed...
>
> --- 25/fs/reiserfs/inode.c~reiserfs-readpages-fix	Sun Nov 10 10:44:28 2002
> +++ 25-akpm/fs/reiserfs/inode.c	Sun Nov 10 10:44:39 2002
> @@ -2081,7 +2081,7 @@ static int reiserfs_readpage (struct fil
>  }
>
>  static int
> -reiserfs_readpages(struct address_space *mapping,
> +reiserfs_readpages(struct file *file, struct address_space *mapping,
>                 struct list_head *pages, unsigned nr_pages)
>  {
>      return mpage_readpages(mapping, pages, nr_pages, reiserfs_get_block);

That fixes it.

Thanks
Ed Tomlinson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
