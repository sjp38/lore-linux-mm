Message-ID: <3A97273B.6007463@amis.com>
Date: Fri, 23 Feb 2001 20:15:07 -0700
From: Eric Whiting <ewhiting@amis.com>
MIME-Version: 1.0
Subject: Re: large mem, heavy paging issues (256M VmStk on Athlon)
References: <Pine.LNX.4.31.0102232136210.8568-100000@localhost.localdomain>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> If your lisp engine is dynamically linked to glibc, a simple
> glibc upgrade should do the trick (if this thing is fixed in
> newer glibcs).
> 
> > I think the strace showed the process is using mainly malloc (mmap)
> > for memory allocation. I do see some brk() calls at the first. (these
> > appear to be returning a 2G number not a 1G number like you suggested)
> 
> > brk(0x805a000)                          = 0x805a000
> 
> Actually, this would be 0x0805a000 if you wrote out the leading
> 0 ... this is more like 128 MB ;)

oops -- yes I need to count digits better.

The mmaps look ok however:

HERE is a successful malloc of 1.7G
 
old_mmap(0x57bf4000, 1731616768, PROT_READ|PROT_WRITE|PROT_EXEC,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) =
0x57bf4000                        

I'll go back to the application and work on this from some other
angles.

Thanks for the sanity check and suggestions.

eric


> 
> regards,
> 
> Rik
> --
> Virtual memory is like a game you can't win;
> However, without VM there's truly nothing to lose...
> 
>                 http://www.surriel.com/
> http://www.conectiva.com/       http://distro.conectiva.com.br/
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
