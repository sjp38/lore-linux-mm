Date: Mon, 9 Oct 2000 13:52:21 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <20001009220606.A20457@gruyere.muc.suse.de>
Message-ID: <Pine.LNX.4.10.10010091350030.1438-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 9 Oct 2000, Andi Kleen wrote:
> 
> netscape usually has child processes: the dns helper. 

Yeah.

One thing we _can_ (and probably should do) is to do a per-user memory
pressure thing - we have easy access to the "struct user_struct" (every
process has a direct pointer to it), and it should not be too bad to
maintain a per-user "VM pressure" counter.

Then, instead of trying to use heuristics like "does this process have
children" etc, you'd have things like "is this user a nasty user", which
is a much more valid thing to do and can be used to find people who fork
tons of processes that are mid-sized but use a lot of memory due to just
being many..

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
