Date: Tue, 10 Oct 2000 11:57:40 -0700
From: Tom Rini <trini@kernel.crashing.org>
Subject: Re: [PATCH] OOM killer API (was: [PATCH] VM fix for 2.4.0-test9 & OOM handler)
Message-ID: <20001010115740.B3468@opus.bloom.county>
References: <20001010170708.C784@nightmaster.csn.tu-chemnitz.de> <Pine.LNX.4.21.0010101231120.11122-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010101231120.11122-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Tue, Oct 10, 2000 at 12:32:50PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 10, 2000 at 12:32:50PM -0300, Rik van Riel wrote:
> On Tue, 10 Oct 2000, Ingo Oeser wrote:
> 
> > before you argue endlessly about the "Right OOM Killer (TM)", I
> > did a small patch to allow replacing the OOM killer at runtime.
> > 
> > So now you can stop arguing about the one and only OOM killer,
> > implement it, provide it as module and get back to the important
> > stuff ;-)
> 
> This is definately a cool toy for people who have doubts
> that my OOM killer will do the wrong thing in their
> workloads.

I think this can be useful for more than just a cool toy.  I think that the
main thing that this discusion has shown is no OOM killer will please 100% of
the people 100% of the time.  I think we should try and have a good generic
OOM killer that kills the right process most of the time.  People can impliment
(and submit) different-style OOM killers as needed.  Or at least get 'em on
freshmeat. :)

-- 
Tom Rini (TR1265)
http://gate.crashing.org/~trini/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
