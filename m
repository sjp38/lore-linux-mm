Date: Tue, 31 Oct 2000 14:11:24 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: kmalloc() allocation.
In-Reply-To: <20001031161753.F7204@nightmaster.csn.tu-chemnitz.de>
Message-ID: <Pine.LNX.4.21.0010311410440.23139-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: "Richard B. Johnson" <root@chaos.analogic.com>, Linux kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 31 Oct 2000, Ingo Oeser wrote:
> On Tue, Oct 31, 2000 at 11:35:46AM -0200, Rik van Riel wrote:
> > > Rik: What do you think about this (physical cont. area cache) for 2.5?
>                                        ^^^^^^^^^^^^^^^^^^^^^^^^^ == PCAC
> > 
> > http://www.surriel.com/zone-alloc.html
> 
> Read it when you published it first, but didn't notice you still
> worked on it ;-)
> 
> My approach is still different. We get the HINT for free. And
> your zone only shift this problem from page to mem_zone level.

It's a nice idea, but you still want to be sure you won't
allocate eg. page tables randomly in the middle of the
PCACs ;)

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
