Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1DFUsl-0006xI-8q
	for linux-mm@kvack.org; Sun, 27 Mar 2005 12:20:35 +0200
Received: from 212.242.189.63 ([212.242.189.63])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sun, 27 Mar 2005 12:20:35 +0200
Received: from martin by 212.242.189.63 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sun, 27 Mar 2005 12:20:35 +0200
From: Martin Egholm Nielsen <martin@egholm-nielsen.dk>
Subject: Re: Overcommit problem on embedded device with no swap
Date: Sun, 27 Mar 2005 12:11:14 +0200
Message-ID: <d260r3$9n2$1@sea.gmane.org>
References: <d1eafk$fdh$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
In-Reply-To: <d1eafk$fdh$1@sea.gmane.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I kinda guess by now this was not the prober place for this question - 
any idea where I could take it?

BR,
  Martin Egholm

> I don't know if this is the right place to go with this problem, but 
> having searched the web, I ended up here... Sorry if this is totally OT.
> 
> Specs:
> I'm having an embedded Linux system running on a PPC405EP with 64 megs 
> of RAM, some flash, but _no_ swap space. It runs a 2.4.20 kernel patched 
> with drivers for my device.
> 
> Problem:
> I have an application that is killed by the OOM (I guess) when it tries 
> to "use" more memory than present on the system.
> Bolied down, memory is allocated with "sbrk" and then touch'ed.
> 
> With "/proc/sys/vm/overcommit_memory" set to 2, I expected that "sbrk" 
> would return "-1" (0xFFFFFFFF), but it doesn't, hence is 
> terminated/killed by the kernel.
> 
> The same happens on another embedded Linux/2.4.17/i386, also without swap.
> 
> However, both my desktop Linux/2.4.18/i386 and Linux/2.6.5/i386 with 
> swap does what I hoped:
> 
> # ./exhaust_mem
> ...
> ffffffff
> 
> Out of memory
> # #Yeaaaah!
> 
> Having searched the web, I see that this may be related with the fact 
> that there is no swap enabled on either of my embedded devices.
> Is this correct?
> Can I do anything in order to get it the way I expected?
> 
> Best regards,
>  Martin Egholm
> 
> === exhaust_mem.c ===
> 
> #include <unistd.h>
> #include <stdio.h>
> #define SIZE 1000000
> 
> int main( int i )
> {
>   while ( 1 ) {
>     char *v = sbrk( SIZE );
>     char *p;
> 
>     printf( "%x\n\n", v );
> 
>     if ((long)v < 0) {
>       fprintf(stderr, "Out of memory\n");
>       exit(1);
>     } // if
> 
>     for (p = v; p < v + SIZE; ++p) {
>       *p = 42;
>     } // for
> 
>   } // while
> } // main
> 
> 
> -- 
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
