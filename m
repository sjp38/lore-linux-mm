Date: Tue, 30 Jul 2002 10:19:32 +0500 (GMT+0500)
From: Anil Kumar <anilk@cdotd.ernet.in>
Subject: Re: Regarding Page Cache ,Buffer Cachein  disabling in Linux Kernel.
In-Reply-To: <Pine.LNX.4.44L.0207291122310.3086-100000@imladris.surriel.com>
Message-ID: <Pine.OSF.4.10.10207301003300.3850-100000@moon.cdotd.ernet.in>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello All,
  
> On Mon, 29 Jul 2002, Anil Kumar wrote:
> 
> >   I am new to this mailing list.I am going through the linux kernel
> >  source code. I want to disable the Page Caching,Buffer Caching  in
> >  the Kernel.How can i do it  ?
> 
> You cannot disable it, without the page cache read(2) and write(2)
> don't have a target to read or write data to/from...
> 
  On My board i have RAM of 8 MB and swapping is disabled.when my 
 system comes up i download binaries (Linux Kernel + Other Application
 Binaries) from flash on the board to the RAM and start processing.

  As i think if 

 a) i allow page caching then there is going to be 2 copies of
  data in my system and i want to avoid it.

 b) Always  my process pages are going to be in RAM and there would be
    no page fault(Unless application have bugs b'se swapping is 
    disabled).
  
   
Regards
Anil


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
