Date: Wed, 7 Mar 2001 18:23:18 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: Bug? in 2.4 memory management...
In-Reply-To: <01030712333600.03019@xerxes>
Message-ID: <Pine.LNX.4.21.0103071821510.867-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?q?Jos=E9=20Manuel=20Rom=E1n=20Ram=EDrez?= <uzi@xerxes.conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 7 Mar 2001, Jose Manuel Roman Ramirez wrote:

> Hi,
> I think we've 'discovered' a bug regarding the kernel 2.4.2-ac11 (and maybe 
> other) and the memory management. It seems that the cached memory sometimes 
> is not freed as more memory is required. 
> 
> The system where we have detected the problem was an athlon 1ghz, 1.2gb of 
> ram, and a swapfile of 2gb.
> 
> When we run a program that requires/uses 1ghz of memory, and we kill it, all 
> (or nearly all) the memory is used by the cache, as we load a hugue file. The 
> next time we run the program, it seems like the kernel can't use the cached 
> memory and the memory we need is taken from the swap. Note however that when 
> we set a swap partition smaller than the memory required, let's say 128mb, 
> the problem disappears as the cache memory is used instead the swap...
> 
> So, what's wrong? Thanks in advance!

VM balance is not quite right. 

Could you please try ac12 (which has a patch to tune the VM a bit) and
report results?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
