Date: Mon, 29 Jan 2001 19:47:54 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] guard mm->rss with page_table_lock (241p11)
In-Reply-To: <20010129224311.H603@jaquet.dk>
Message-ID: <Pine.LNX.4.21.0101291946540.1321-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rasmus Andersen <rasmus@jaquet.dk>
Cc: torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2001, Rasmus Andersen wrote:
> On Mon, Jan 29, 2001 at 07:30:01PM -0200, Rik van Riel wrote:
> > On Mon, 29 Jan 2001, Rasmus Andersen wrote:
> > 
> > > Please comment. Or else I will continue to sumbit it :)
> > 
> > The following will hang the kernel on SMP, since you're
> > already holding the spinlock here. Try compiling with
> > CONFIG_SMP and see what happens...
> 
> You are right. Sloppy research by me :(
> 
> New patch below with the vmscan part removed.

Have you bothered to also check the rest?

Don't be surprised if there are more places
like this. Please compile your kernel with
CONFIG_SMP and test if your changes work
before submitting them into the stable kernel.

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
