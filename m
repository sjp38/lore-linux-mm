Date: Mon, 25 Sep 2000 15:49:52 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
Message-ID: <20000925154952.O26339@suse.de>
References: <20000925145856.A13011@athlon.random> <Pine.LNX.4.21.0009251504220.6224-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251504220.6224-100000@elte.hu>; from mingo@elte.hu on Mon, Sep 25, 2000 at 03:10:51PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25 2000, Ingo Molnar wrote:
> > If you think I should delay those fixes to do something else I don't
> > agree sorry.
> 
> no, i never ment it. I find it very good that those half-done changes are

The changes made were never half-done. The recent bug fixes have
mainly been to remove cruft from the earlier elevator and fixing a bug
where the elevator insert would screw up a bit. So I'd call that fine
tuning or adjusting, not fixing half-done stuff.

> cleaned up and the remaining bugs / performance problems are eliminated -

Of course

> the first reports about bad write performance came right after the
> original elevator patches went in, about 6 months ago.

And a new elevator was introduced some months ago to solve this.

-- 
* Jens Axboe <axboe@suse.de>
* SuSE Labs
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
