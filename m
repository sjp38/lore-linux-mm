Message-ID: <393EADB0.54FB3633@reiser.to>
Date: Wed, 07 Jun 2000 13:16:48 -0700
From: Hans Reiser <hans@reiser.to>
MIME-Version: 1.0
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:
 it'snot just the code)
References: <20000607144102.F30951@redhat.com> <Pine.LNX.4.21.0006071103560.14304-100000@duckman.distro.conectiva> <20000607154620.O30951@redhat.com> <yttog5decvq.fsf@serpe.mitica> <20000607163519.S30951@redhat.com>
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Quintela Carreira Juan J." <quintela@fi.udc.es>, Rik van Riel <riel@conectiva.com.br>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:

> 
> It's a matter of pressure.  The filesystem with most pages in the LRU
> cache, or with the oldest pages there, should stand the greatest chance
> of being the first one told to clean up its act.
> 
> Cheers,
>  Stephen
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.rutgers.edu
> Please read the FAQ at http://www.tux.org/lkml/

The new age one 64th of your objects scheme causes pressure to be
proportional.....

I am looking forward to reading the new 2.4 mm code during my next aeroflot
experience this sunday....

Hans
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
