Date: Mon, 25 Sep 2000 16:05:22 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
Message-ID: <20000925160522.Q26339@suse.de>
References: <20000925154952.O26339@suse.de> <Pine.LNX.4.21.0009251608570.9122-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251608570.9122-100000@elte.hu>; from mingo@elte.hu on Mon, Sep 25, 2000 at 04:11:45PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25 2000, Ingo Molnar wrote:
> > The changes made were never half-done. The recent bug fixes have
> > mainly been to remove cruft from the earlier elevator and fixing a bug
> > where the elevator insert would screw up a bit. So I'd call that fine
> > tuning or adjusting, not fixing half-done stuff.
> 
> sorry i did not mean to offend you - unadjusted and unfixed stuff hanging
> around in the kernel for months is 'half done' for me.

No offense taken, I just tried to explain my view. And in light of
the bad test2, I'd like the new changes to not have any "issues". So
this work has been going on for the last month or so, and I think we are
finally getting to agreement on what needs to be done now and how. WIP.

> > And a new elevator was introduced some months ago to solve this.
> 
> and these are still not solved in the vanilla kernel, as recent complaints
> on l-k prove.

Different problems, though :(. However, I believe they are solved in
Andrea and my current tree. Just needs the final cleaning, more later.

-- 
* Jens Axboe <axboe@suse.de>
* SuSE Labs
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
