Date: Mon, 25 Sep 2000 15:08:58 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VM
Message-ID: <20000925150858.A22882@athlon.random>
References: <20000925150258.B13011@athlon.random> <Pine.LNX.4.21.0009251501020.6224-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251501020.6224-100000@elte.hu>; from mingo@elte.hu on Mon, Sep 25, 2000 at 03:02:58PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 03:02:58PM +0200, Ingo Molnar wrote:
> 
> On Mon, 25 Sep 2000, Andrea Arcangeli wrote:
> 
> > Sorry I totally disagree. If GFP_KERNEL are garanteeded to succeed
> > that is a showstopper bug. [...]
> 
> why?

Because as you said the machine can lockup when you run out of memory.

> FYI, i havent put it there.

Ok.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
