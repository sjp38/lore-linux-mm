Date: Mon, 25 Sep 2000 18:05:32 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
In-Reply-To: <20000925165151.I2615@redhat.com>
Message-ID: <Pine.LNX.4.21.0009251804280.9122-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Stephen C. Tweedie wrote:

> Sorry, but in this case you have got a lot more variables than you
> seem to think.  The obvious lock is the ext2 superblock lock, but
> there are side cases with quota and O_SYNC which are much less
> commonly triggered.  That's not even starting to consider the other
> dozens of filesystems in the kernel which have to be audited if we
> change the locking requirements for GFP calls.

i'd suggest to simply BUG() in schedule() if the superblock lock is held
not directly by lock_super. Holding the superblock lock is IMO quite rude
anyway (for performance and latency) - is there any place where we hold it
for a long time and it's unavoidable?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
