Date: Tue, 31 Oct 2000 11:35:46 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: kmalloc() allocation.
In-Reply-To: <20001031114851.D7204@nightmaster.csn.tu-chemnitz.de>
Message-ID: <Pine.LNX.4.21.0010311134590.23139-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: "Richard B. Johnson" <root@chaos.analogic.com>, Linux kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 31 Oct 2000, Ingo Oeser wrote:
> On Mon, Oct 30, 2000 at 02:40:16PM -0200, Rik van Riel wrote:

> > If you write the defragmentation code for the VM, I'll
> > be happy to bump up the limit a bit ...
> 
> Should become easier once we start doing physical page scannings.
> 
> We could record physical continous freeable areas on the fly
> then. If someone asks for them later, we recheck whether they
> still exists and free (inactive_clean) or remap (active or
> inactive_dirty) the whole area, whether they are used or not. 
> 
> This could still be improved by using up smallest fit areas
> first for kmalloc() based on these areas.

> Rik: What do you think about this (physical cont. area cache) for 2.5?

http://www.surriel.com/zone-alloc.html

cheers,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
