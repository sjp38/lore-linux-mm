Date: Tue, 26 Sep 2000 17:29:27 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: [CFT][PATCH] ext2 directories in pagecache
In-Reply-To: <Pine.GSO.4.21.0009250101150.14096-100000@weyl.math.psu.edu>
Message-ID: <Pine.GSO.4.21.0009261715320.22614-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, Alexander Viro <aviro@redhat.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

be really working (survives assorted builds, does the right thing on
find-based scripts and obvious local tests, yodda, yodda). It certainly
needs more testing, but I would call it (early) beta.

	Folks, give it a try - just keep decent backups. Similar code will
have to go into UFS in 2.4 and that (ext2) variant may be of interest for
2.4.<late>/2.5.<early> timeframe.

	I'm putting it on ftp.math.psu.edu/pub/viro/ext2-patch-7.gz.
Comments and help in testing are more than welcome.
							Cheers,
								Al


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
