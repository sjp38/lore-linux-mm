Date: Mon, 6 Nov 2000 17:12:04 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: PATCH [2.4.0test10]: Kiobuf#02, fault-in fix
Message-ID: <20001106171204.B22626@athlon.random>
References: <20001102134021.B1876@redhat.com> <20001103232721.D27034@athlon.random> <20001106150539.A19112@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20001106150539.A19112@redhat.com>; from sct@redhat.com on Mon, Nov 06, 2000 at 03:05:39PM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@nl.linux.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 06, 2000 at 03:05:39PM +0000, Stephen C. Tweedie wrote:
> Why?

I think to avoid losing a write.


	handle_mm_fault()
	pte is dirty
					pager write it out and make it clean
					since it's not pinned on the
					physical side yet so it's allowed
	grab pagetable lock
	follow_page()
	pte is writeable but not dirty
	pin the page on the physical side to inibith the swapper
	unlock the pagetable lock

	read from disk and write to memory

	now the pte is clean and the page won't be synced back while
	closing the file or during msync

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
