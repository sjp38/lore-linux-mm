Date: Mon, 25 Sep 2000 16:11:45 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
In-Reply-To: <20000925154952.O26339@suse.de>
Message-ID: <Pine.LNX.4.21.0009251608570.9122-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@suse.de>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Jens Axboe wrote:

> The changes made were never half-done. The recent bug fixes have
> mainly been to remove cruft from the earlier elevator and fixing a bug
> where the elevator insert would screw up a bit. So I'd call that fine
> tuning or adjusting, not fixing half-done stuff.

sorry i did not mean to offend you - unadjusted and unfixed stuff hanging
around in the kernel for months is 'half done' for me.

> > the first reports about bad write performance came right after the
> > original elevator patches went in, about 6 months ago.
> 
> And a new elevator was introduced some months ago to solve this.

and these are still not solved in the vanilla kernel, as recent complaints
on l-k prove.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
