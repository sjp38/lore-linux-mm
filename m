Date: Sat, 17 Jun 2000 12:23:27 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: kswapd eating too much CPU on ac16/ac18
In-Reply-To: <Pine.Linu.4.10.10006170555400.662-100000@mikeg.weiden.de>
Message-ID: <Pine.LNX.4.21.0006171222470.31955-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@weiden.de>
Cc: Cesar Eduardo Barros <cesarb@nitnet.com.br>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 17 Jun 2000, Mike Galbraith wrote:
> On Sat, 17 Jun 2000, Cesar Eduardo Barros wrote:
> 
> > > OTOH, I can imagine it being better if you have a very small
> > > LRU cache, something like less than 1/2 MB.
> > 
> > You can imagine it being better in some random rare condition I don't care
> > about. People have been noticing speed problems related to kswapd. This is not
> > microkernel research.
> 
> ahem.
> 
> If you can do better, please do.   If not, give the man the feedback
> he needs to find/fix the problems and spare us such useless comments.

Nah, all he wrote down was that I shouldn't care about his
situation because he doesn't care about it either ;)

(read the thread carefully ... this is just about what he
said)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
