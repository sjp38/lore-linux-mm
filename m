Message-ID: <20020920143536.58257.qmail@mail.com>
Content-Type: text/plain; charset="iso-8859-15"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
From: "Lee Chin" <leechin@mail.com>
Date: Fri, 20 Sep 2002 09:35:36 -0500
Subject: Re: memory allocation on linux
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br, leechin@mail.com
Cc: "Cannizzaro, Emanuele" <ecannizzaro@mtc.ricardo.com>, ebiederm+eric@ccr.net, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi
>If you link your program statically
>you might be able to get up to nearly 3 GB of >memory for your
>process, but that's the limit...
Is that on a 32 bith machine that I can get upto 3GB?  I have linked statically, but yet I max out at 2 GB.  I thoiught with th elatest kernel, which already includes the BIGMEM patch, I should be able to go upto 3GB.

Thanks
Lee

----- Original Message -----
From: Rik van Riel <riel@conectiva.com.br>
Date: 	Thu, 19 Sep 2002 22:03:31 -0300 (BRT)
To: Lee Chin <leechin@mail.com>
Subject: Re: memory allocation on linux


> On Thu, 19 Sep 2002, Lee Chin wrote:
> 
> > I have a process trying to allocate a large amount of memory.
> > I have 4 GB physical memory in the system and more with swap space.
> 
> > However, I am unable to allocate more than 2GB for my process.
> > How can I acheive this?
> 
> Switch to a 64-bit CPU.  If you link your program statically
> you might be able to get up to nearly 3 GB of memory for your
> process, but that's the limit...
> 
> Rik
> -- 
> Bravely reimplemented by the knights who say "NIH".
> 
> http://www.surriel.com/		http://distro.conectiva.com/
> 
> Spamtraps of the month:  september@surriel.com trac@trac.org
> 
> 

-- 
__________________________________________________________
Sign-up for your own FREE Personalized E-mail at Mail.com
http://www.mail.com/?sr=signup

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
