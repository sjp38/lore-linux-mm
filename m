Date: Mon, 25 Sep 2000 18:20:40 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
In-Reply-To: <Pine.GSO.4.21.0009251157390.16980-100000@weyl.math.psu.edu>
Message-ID: <Pine.LNX.4.21.0009251819380.9122-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Alexander Viro wrote:

> > i'd suggest to simply BUG() in schedule() if the superblock lock is held
> > not directly by lock_super. Holding the superblock lock is IMO quite rude
> > anyway (for performance and latency) - is there any place where we hold it
> > for a long time and it's unavoidable?
> 
> Ingo, schedule() has no bloody business _knowing_ about superblock
> locks in the first place. Yes, ext2 should not bother taking it at
> all. For completely unrelated reasons.

i only suggested this as a debugging helper, instead of the suggested
ext2_getblk() BUG() helper. Obviously schedule() has no business knowing
about filesystem locks.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
