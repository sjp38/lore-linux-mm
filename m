From: volodya@mindspring.com
Date: Fri, 23 Jun 2000 11:36:49 -0400 (EDT)
Reply-To: volodya@mindspring.com
Subject: Re: [RFC] RSS guarantees and limits
In-Reply-To: <Pine.LNX.4.21.0006231045220.4551-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.20.0006231126110.1106-100000@node2.localnet.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ed Tomlinson <tomlins@cam.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

What about making some userspace hooks available and leaving the task to a
daemon ?

  * pseudo-single mode: when memory pressure reserver a fixeed amount of
    for root user owned fixed list of processes
  * simple swapout algorithm (like in 2.0.x) by default
  * hooks to allow a userspace program do all clever things as needed.
    (partially mlocked userspace program ?)

why: 
  * it was a while this discussion is going on, a userspace solution will
    allow more space for experimentation without risk of corrupting kernel
    data 

  * isolate data collection and memory reclaim interfaces (I admit I am
    vague on this part...) from the logic that takes decisiions

  * swapping data out is expensive anyway (but reclaimation in read-only
    mmaped files is not...)  
 
  * userspace daemons can differ for different setups. What is more one 
    can direct them to do something specific when, say, running squid,
    apache or something very particular..

  * when we know what to do and what works merge them back into kernel 
    (perhaps as kmod or perhaps as khttpd)


                          Vladimir Dergachev


On Fri, 23 Jun 2000, Rik van Riel wrote:

> On Thu, 22 Jun 2000, Ed Tomlinson wrote:
> 
> > Just wondering what will happen with java applications?  These
> > beasts typically have working sets of 16M or more and use 10-20
> > threads.  When using native threads linux sees each one as a
> > process.  They all share the same memory though.
> 
> Ahh, but these limits are of course applied per _MM_, not
> per thread ;)
> 
> regards,
> 
> Rik
> --
> The Internet is not a network of computers. It is a network
> of people. That is its real strength.
> 
> Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
> http://www.conectiva.com/		http://www.surriel.com/
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
