Date: Tue, 26 Sep 2000 09:42:39 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: [CFT][PATCH] ext2 directories in pagecache
In-Reply-To: <Pine.GSO.4.21.0009250101150.14096-100000@weyl.math.psu.edu>
Message-ID: <Pine.GSO.4.21.0009260834480.19849-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, Alexander Viro <aviro@redhat.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Help in testing is welcome, just keep in mind that it's ext2 we are
talking about. IOW, proceed with care and don't let it loose on the data
you can't easily restore.
	Patch moves the directory data into the pagecache. I hope that
it's sufficiently straightforward to be readable.
	Linus, if you prefer to get it in the mail - tell and I'll send it
(50K unpacked due to ext2/{dir,namei}.c modifications, so it's too large
for the lists).
							Cheers,
								Al


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
