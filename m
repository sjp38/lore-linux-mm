Date: Tue, 26 Sep 2000 19:44:28 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: [CFT][PATCH] ext2 directories in pagecache
In-Reply-To: <Pine.LNX.4.10.10009261931550.5176-100000@aviro.devel.redhat.com>
Message-ID: <Pine.GSO.4.21.0009261936000.22614-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <aviro@redhat.com>
Cc: Andreas Dilger <adilger@turbolinux.com>, Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Tue, 26 Sep 2000, Alexander Viro wrote:

> On Tue, 26 Sep 2000, Andreas Dilger wrote:
> 
> > Al Viro writes:
> > > 	Folks, give it a try - just keep decent backups. Similar code will
> > > have to go into UFS in 2.4 and that (ext2) variant may be of interest for
> > > 2.4.<late>/2.5.<early> timeframe.
> > 
> > Haven't tested it yet, but just reading over the patch - in ext2_lookup():
> > 
> >         if (dentry->d_name.len > UFS_MAXNAMLEN)
> >                 return ERR_PTR(-ENAMETOOLONG)
> > 
> > should probably be changed back to:
> > 
> >         if (dentry->d_name.len > EXT2_NAME_LEN)
> >                 return ERR_PTR(-ENAMETOOLONG)
> 
> Grrr... It shows the ancestry - it's a ported UFS patch. Thanks for spotting,
> I'll fix that.

Aha. And there was that UFS_LINK_MAX thing. Fixed. OK, new version is on
the same site, URL being ftp://ftp.math.psu.edu/pub/viro/ext2-patch-8.gz

	Changes: got rid of the remnants of UFS ancestry (EXT2 limits are
used; not that it mattered much, but...), fixed the conversion in
ext2_empty_dir() (cpu_to_le32() instead of le32_to_cpu()).
							Cheers,
								Al

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
