Date: Mon, 27 Mar 2000 12:50:17 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [RFT] balancing patch
In-Reply-To: <Pine.LNX.4.10.10003270756160.2378-100000@coffee.psychology.mcmaster.ca>
Message-ID: <Pine.LNX.4.21.0003271244470.1104-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Mon, 27 Mar 2000, Mark Hahn wrote:

> > see whether it helps them. If you try the patch, and see that it
> > helps, or hinders, your system performance, please let me know. 
> 
> doesn't help: kswapd still wastes major CPU.

I'm now testing Kanoj' balancing patch together with my kswapd
infinite-loop-removal patch. The system seems to work quite well,
I haven't seen any big strangeness in the VM load (the variance
in the amount of free memory is a bit bigger, naturally, but that's
to be expected) and interactive performance from the console seems
unaffected.

It would be nice if a few more people tested the combination of
2.3.99-pre3 with Kanoj' balancing patch and my infinite-loop-
removal patch ...   (because YMMV)

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
