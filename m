Date: Mon, 25 Sep 2000 15:12:58 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: the new VM
In-Reply-To: <20000925150858.A22882@athlon.random>
Message-ID: <Pine.LNX.4.21.0009251511050.6224-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Andrea Arcangeli wrote:

> > > Sorry I totally disagree. If GFP_KERNEL are garanteeded to succeed
> > > that is a showstopper bug. [...]
> > 
> > why?
> 
> Because as you said the machine can lockup when you run out of memory.

well, i think all kernel-space allocations have to be limited carefully,
denying succeeding allocations is not a solution against over-allocation,
especially in a multi-user environment.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
