Date: Tue, 10 Oct 2000 17:58:46 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] OOM killer API (was: [PATCH] VM fix for 2.4.0-test9 &
 OOM handler)
In-Reply-To: <20001010115740.B3468@opus.bloom.county>
Message-ID: <Pine.LNX.4.21.0010101757350.11122-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tom Rini <trini@kernel.crashing.org>
Cc: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Oct 2000, Tom Rini wrote:
> On Tue, Oct 10, 2000 at 12:32:50PM -0300, Rik van Riel wrote:
> > On Tue, 10 Oct 2000, Ingo Oeser wrote:
> > 
> > > before you argue endlessly about the "Right OOM Killer (TM)", I
> > > did a small patch to allow replacing the OOM killer at runtime.
> > > 
> > > So now you can stop arguing about the one and only OOM killer,
> > > implement it, provide it as module and get back to the important
> > > stuff ;-)
> > 
> > This is definately a cool toy for people who have doubts
> > that my OOM killer will do the wrong thing in their
> > workloads.
> 
> I think this can be useful for more than just a cool toy.  I
> think that the main thing that this discusion has shown is no
> OOM killer will please 100% of the people 100% of the time.  I
> think we should try and have a good generic OOM killer that
> kills the right process most of the time.  People can impliment
> (and submit) different-style OOM killers as needed.

Indeed, though I suspect most of the people trying this would
fall into the trap of over-engineering their OOM killer, after
which it mostly becomes less predictable ;)

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
