Date: Tue, 26 Sep 2000 00:28:12 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000926002812.C5010@athlon.random>
References: <20000925213242.A30832@athlon.random> <Pine.LNX.4.21.0009251622500.4997-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251622500.4997-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Sep 25, 2000 at 04:26:17PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 04:26:17PM -0300, Rik van Riel wrote:
> > > It doesn't --- that is part of the design.  The vm scanner propagates
> > 
> > And that's the inferior part of the design IMHO.
> 
> Indeed, but physical page based aging is a definate
> 2.5 thing ... ;(

I'm talking about the fact that if you have a file mmapped in 1.5G of RAM
test9 will waste time rolling between LRUs 384000 pages, while classzone
won't ever see 1 of those pages until you run low on fs cache.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
