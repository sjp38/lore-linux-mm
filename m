Message-Id: <99Nov3.154619gmt.66624@gateway.ukaea.org.uk>
Date: Wed, 3 Nov 1999 15:46:33 +0000
From: Neil Conway <nconway.list@ukaea.org.uk>
MIME-Version: 1.0
Subject: Re: The 64GB memory thing
References: <Pine.LNX.4.10.9911031654080.7408-100000@chiara.csoma.elte.hu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> 
> On Wed, 3 Nov 1999, Neil Conway wrote:
> 
> > The recent thread about >4GB surprised me, as I didn't even think >2GB
> > was very stable yet.  Am I wrong?  Are people out there using 4GB
> > boxes with decent stability?  I presume it's a 2.3 feature, yes?
> 
> the 64GB stuff got included recently. It's a significant rewrite of the
> lowlevel x86 MM and generic MM layer, here is a short description about
> it:
> 
> my 'HIGHMEM patch' went into the 2.3 kernel starting at pre4-2.3.23. This
> ...

Wow, that's good news.  But hang on a second, ;-) wasn't there a feature
freeze at 2.3.18?
And presumably each process is still limited to a 32-bit address space,
right?

As for stability, anyone got any comments?

> 64 GB PAE mode works just fine on my 8GB RAM, 8-way Xeon box:

Mmmmm :-)  Could you give us the source and a ballpark price on that
please?

thanks for the update,
Neil
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
