Date: Mon, 9 Oct 2000 22:58:22 +0200
From: "Andi Kleen" <ak@suse.de>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001009225822.A21401@gruyere.muc.suse.de>
References: <20001009220606.A20457@gruyere.muc.suse.de> <Pine.LNX.4.10.10010091350030.1438-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.10.10010091350030.1438-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Mon, Oct 09, 2000 at 01:52:21PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 09, 2000 at 01:52:21PM -0700, Linus Torvalds wrote:
> One thing we _can_ (and probably should do) is to do a per-user memory
> pressure thing - we have easy access to the "struct user_struct" (every
> process has a direct pointer to it), and it should not be too bad to
> maintain a per-user "VM pressure" counter.
> 
> Then, instead of trying to use heuristics like "does this process have
> children" etc, you'd have things like "is this user a nasty user", which
> is a much more valid thing to do and can be used to find people who fork
> tons of processes that are mid-sized but use a lot of memory due to just
> being many..

Would not help much when "they" eat your memory by loading big bitmaps
into the X server which runs as root (it seems there are many programs
which are very good at this particular DOS ;) 

Also I think most oom situations are accidents anyways, not malicious users.
When you're the only user of the machine sophisticated per user accouting
won't be very useful. 

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
