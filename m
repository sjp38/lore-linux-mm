Date: Tue, 26 Sep 2000 19:33:10 -0400 (EDT)
From: Alexander Viro <aviro@redhat.com>
Subject: Re: [CFT][PATCH] ext2 directories in pagecache
In-Reply-To: <200009262319.e8QNJP226895@webber.adilger.net>
Message-ID: <Pine.LNX.4.10.10009261931550.5176-100000@aviro.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Dilger <adilger@turbolinux.com>
Cc: Alexander Viro <viro@math.psu.edu>, Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, Alexander Viro <aviro@redhat.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>



On Tue, 26 Sep 2000, Andreas Dilger wrote:

> Al Viro writes:
> > 	Folks, give it a try - just keep decent backups. Similar code will
> > have to go into UFS in 2.4 and that (ext2) variant may be of interest for
> > 2.4.<late>/2.5.<early> timeframe.
> 
> Haven't tested it yet, but just reading over the patch - in ext2_lookup():
> 
>         if (dentry->d_name.len > UFS_MAXNAMLEN)
>                 return ERR_PTR(-ENAMETOOLONG)
> 
> should probably be changed back to:
> 
>         if (dentry->d_name.len > EXT2_NAME_LEN)
>                 return ERR_PTR(-ENAMETOOLONG)

Grrr... It shows the ancestry - it's a ported UFS patch. Thanks for spotting,
I'll fix that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
