Date: Fri, 17 Aug 2001 23:25:06 +0200
From: Pavel Machek <pavel@suse.cz>
Subject: Re: Swapping for diskless nodes
Message-ID: <20010817232506.B19037@atrey.karlin.mff.cuni.cz>
References: <Pine.LNX.4.33L.0108162146120.5646-100000@imladris.rielhome.conectiva> <3B7CBCD0.CD209D84@xss.co.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3B7CBCD0.CD209D84@xss.co.at>; from andreas@xss.co.at on Fri, Aug 17, 2001 at 08:42:24AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Haumer <andreas@xss.co.at>
Cc: Rik van Riel <riel@conectiva.com.br>, Pavel Machek <pavel@suse.cz>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Bulent Abali <abali@us.ibm.com>, "Dirk W. Steinberg" <dws@dirksteinberg.de>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> > On Thu, 16 Aug 2001, Pavel Machek wrote:
> > 
> > > I'd call that configuration error. If swap-over-nbd works in all but
> > > such cases, its okay with me.
> > 
> > Agreed. I'm very interested in this case too, I guess we
> > should start testing swap-over-nbd and trying to fix things
> > as we encounter them...
> > 
> We do "testing" swap-over-nbd for some time now... :-))
> 
> In fact, all our workstations in our office are xS+S Diskless Clients, 
> and about 50 Diskless Clients are running at several customer sites.
> 
> In order to make Pavel happy :-) we did some more stress testing
> now, and here are the results:

Pavel is happy ;-).

> We set up a quite old machine (ASUS P55T2P4 motherboard,
> 64MB RAM, AMD K6/200 CPU, Matrox Millenium II graphics card,
> RTL8139 100MBit Ethernet) as Diskless Client with NBD Swap.
> 
> We installed our up-coming BLD-3.1 with Linux-2.2.19 kernel,
> Etherboot+initrd, DevFS and NBD swap patches.

Can you revert NBD swap patch and try again? It should break. If it
does not break, your testing is not good enough.
								Pavel
-- 
The best software in life is free (not shareware)!		Pavel
GCM d? s-: !g p?:+ au- a--@ w+ v- C++@ UL+++ L++ N++ E++ W--- M- Y- R+
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
