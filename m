From: Andreas Dilger <adilger@turbolinux.com>
Message-Id: <200009262319.e8QNJP226895@webber.adilger.net>
Subject: Re: [CFT][PATCH] ext2 directories in pagecache
In-Reply-To: <Pine.GSO.4.21.0009261715320.22614-100000@weyl.math.psu.edu>
 "from Alexander Viro at Sep 26, 2000 05:29:27 pm"
Date: Tue, 26 Sep 2000 17:19:22 -0600 (MDT)
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, Alexander Viro <aviro@redhat.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Al Viro writes:
> 	Folks, give it a try - just keep decent backups. Similar code will
> have to go into UFS in 2.4 and that (ext2) variant may be of interest for
> 2.4.<late>/2.5.<early> timeframe.

Haven't tested it yet, but just reading over the patch - in ext2_lookup():

        if (dentry->d_name.len > UFS_MAXNAMLEN)
                return ERR_PTR(-ENAMETOOLONG)

should probably be changed back to:

        if (dentry->d_name.len > EXT2_NAME_LEN)
                return ERR_PTR(-ENAMETOOLONG)

Cheers, Andreas
-- 
Andreas Dilger  \ "If a man ate a pound of pasta and a pound of antipasto,
                 \  would they cancel out, leaving him still hungry?"
http://www-mddsp.enel.ucalgary.ca/People/adilger/               -- Dogbert
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
