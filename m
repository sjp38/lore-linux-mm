Date: Tue, 24 Oct 2000 18:16:31 -0600
From: "Jeff V. Merkey" <jmerkey@vger.timpanogas.org>
Subject: Re: PATCH: killing read_ahead[]
Message-ID: <20001024181631.B14069@vger.timpanogas.org>
References: <39F5DAF5.1D3662BD@mandrakesoft.com> <Pine.LNX.4.10.10010241245280.1704-100000@penguin.transmeta.com> <20001025003049.E18138@nightmaster.csn.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20001025003049.E18138@nightmaster.csn.tu-chemnitz.de>; from ingo.oeser@informatik.tu-chemnitz.de on Wed, Oct 25, 2000 at 12:30:49AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Jeff Garzik <jgarzik@mandrakesoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 25, 2000 at 12:30:49AM +0200, Ingo Oeser wrote:
> On Tue, Oct 24, 2000 at 12:46:36PM -0700, Linus Torvalds wrote:
> > Actually, the _real_ answer is to make fs/block_dev.c use the page cache
> > instead - and generic_file_read() does read-ahead that actually improves
> > performance, unlike the silly contortions that the direct block-dev
> > read-ahead tries to do.
> 
> If we had a paper about the page cache this would be easy.
> 
> In the beginning page cache was just previously mmaped pages,
> that are clean and ready to be mapped again.
> 
> Today we have them either dirty or clean, mapped or not(?), with and
> without buffers, in highmem(?) or lowmem and everybody and its
> children is using it for everything.
> 
> We need a clear definition about (concurrent) states of page
> cached pages, valid transitions (and locks/sema4s to take for
> them), assumptions, guarantees etc.
> 
> The only thing I see guaranteed, that every big thing to be
> cached should live there and is page aligned and page sized.
> 
> I'm trying hard to understand a concept in the page cache and to
> get it's limits and guarantees, but still find it hard to get
> them.
> 
> Time for specs, I would say ;-)
> 
> I could help to explain and formulate, if someone could only cut
> the edges of how it works and what it will be.
> 
> Thanks & Regards
> 
> Ingo Oeser
> -- 
> Feel the power of the penguin - run linux@your.pc
> <esc>:x
> -

I hope we are not doing something stupid here, like breaking the 
f*!%cking page cache again.  I've finaly got all the bugs out of 
NWFS on 2.4.0-test9, and have waded through the breakage of the 
past two testX releases of 2.4.   

Why do we need to disable read ahead on the page cache anyway?

:-)

Jeff



> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> Please read the FAQ at http://www.tux.org/lkml/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
