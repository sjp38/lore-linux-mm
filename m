Received: from russian-caravan.cloud9.net (russian-caravan.cloud9.net [168.100.1.4])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA22563
	for <linux-mm@kvack.org>; Tue, 19 Jan 1999 21:24:03 -0500
Date: Tue, 19 Jan 1999 15:09:04 -0500 (EST)
From: John Alvord <jalvo@cloud9.net>
Subject: Re: VM20 behavior on a 486DX/66Mhz with 16mb of RAM
In-Reply-To: <199901191802.SAA05794@dax.scot.redhat.com>
Message-ID: <Pine.BSF.4.05.9901191505560.2608-100000@earl-grey.cloud9.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, Nimrod Zimerman <zimerman@deskmail.com>, Linux Kernel mailing list <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Jan 1999, Stephen C. Tweedie wrote:

> Hi,
> 
> On Sat, 16 Jan 1999 14:22:10 +0100 (CET), Andrea Arcangeli
> <andrea@e-mind.com> said:
> 
> > Setting an high limit for the cache when we are low memory is easy doable.
> > Comments from other mm guys?
> 
> Horrible --- smells like the old problem of "oh, our VM is hopeless at
> tuning performance itself, so let's rely on magic numbers to constrain
> it to reasonable performance".  I'd much much much much rather see a VM
> which manages to work well without having to be constrained by tricks
> like that (although by all means supply extra boundary limits for use in
> special cases: just don't enable them on a default system).
> 
We have at least one other case where a memory algorithm needed to be
tuned for smaller memory. It was the "target free space per cent" which
had to be larger for small memory machines. There could be a similiar
effect in cache handling. No problem on larger machines, but a big problem
on small memory machines.

John Alvord

Music, Management, Poetry and more...
           http://www.candlelist.org/kuilema
 
Cheap CDs @ http://www.cruzio.com/~billpeet/MusicByCandlelight
 



--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
