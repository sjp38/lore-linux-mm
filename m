Date: Fri, 17 Aug 2001 23:23:15 +0200
From: Pavel Machek <pavel@suse.cz>
Subject: Re: Swapping for diskless nodes
Message-ID: <20010817232315.A19037@atrey.karlin.mff.cuni.cz>
References: <20010816234639.E755@bug.ucw.cz> <Pine.LNX.4.33L.0108162146120.5646-100000@imladris.rielhome.conectiva> <20010817033551.A2188@unthought.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010817033551.A2188@unthought.net>; from jakob@unthought.net on Fri, Aug 17, 2001 at 03:35:51AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jakob ?stergaard <jakob@unthought.net>, Rik van Riel <riel@conectiva.com.br>, Pavel Machek <pavel@suse.cz>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Bulent Abali <abali@us.ibm.com>, "Dirk W. Steinberg" <dws@dirksteinberg.de>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> > > I'd call that configuration error. If swap-over-nbd works in all but
> > > such cases, its okay with me.
> > 
> > Agreed. I'm very interested in this case too, I guess we
> > should start testing swap-over-nbd and trying to fix things
> > as we encounter them...
> 
> FYI:  The following has been rock solid for the past two days, using the
> machine mainly for emacs/LaTeX/konqueror/...   There's fairly heavy swap
> traffic, often  25-40 MB swap is used.
> 
> joe@rhinehart:~$ free
>              total       used       free     shared    buffers     cached
> Mem:         38052      37164        888      20616       2864      16968
> -/+ buffers/cache:      17332      20720
> Swap:        65528      24788      40740
> joe@rhinehart:~$ uname -a
> Linux rhinehart 2.2.19pre17 #1 Tue Mar 13 22:37:59 EST 2001 i586 unknown
> joe@rhinehart:~$ cat /proc/swaps 
> Filename                        Type            Size    Used    Priority
> /dev/nbd0                       partition       65528   24728   -2
> joe@rhinehart:~$
> 
> I'm swapping over a 3Com 374TX pcmcia card in a 100Mbit hub (hooked up to a
> switch, connected to the nbd-server machine)

Can you try heavy ping -f's onto the swapping machine? Plus put some
*heavy* pressure on it. 40MB in swap is okay .. if you have 8MB main
memory.

								Pavel
-- 
The best software in life is free (not shareware)!		Pavel
GCM d? s-: !g p?:+ au- a--@ w+ v- C++@ UL+++ L++ N++ E++ W--- M- Y- R+
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
