Message-ID: <3B84BE0A.C9082E87@pp.inet.fi>
Date: Thu, 23 Aug 2001 11:25:46 +0300
From: Jari Ruusu <jari.ruusu@pp.inet.fi>
MIME-Version: 1.0
Subject: Re: VM problem with 2.4.8-ac9 (fwd)
References: <Pine.LNX.4.21.0108221526170.2651-100000@freak.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Rik van Riel <riel@conectiva.com.br>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:
> On Wed, 22 Aug 2001, Rik van Riel wrote:
> 
> > Hi Alan,
> >
> > Another report of tasks dying on recent 2.4 kernels.
> > Suspect code would be:
> > - tlb optimisations in recent -ac    (tasks dying with segfault)
> > - swapfile.c, especially sys_swapoff (known race condition, marcelo?)
> 
> There are known races on swapoff, but Jari is not running swapoff...

Correct, not running swapoff.

> >
> > What would cause the swap map badness below I wouldn't know,
> > maybe marcelo is more familiar with the swapfile.c code...
> 
> Jari,
> 
> 1) Are you using an SMP kernel?

No.

> 2) Did you tried with older kernels or 2.4.9?

Linus' 2.4.9 survived about 7 hours of VM torture, and then I got ext2
filesystem corruption (just once, dunno if it is repeatable). No "swap
offset" problems with 2.4.9 so far. Haven't tortured older kernels yet.

Regards,
Jari Ruusu <jari.ruusu@pp.inet.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
