Date: Thu, 4 Jan 2001 11:34:57 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] add PF_MEMALLOC to __alloc_pages()
In-Reply-To: <87g0j0qlvy.fsf@atlas.iskon.hr>
Message-ID: <Pine.LNX.4.21.0101041134300.1188-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko@iskon.hr>
Cc: Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Mike Galbraith <mikeg@wen-online.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 4 Jan 2001, Zlatko Calusic wrote:
> Rik van Riel <riel@conectiva.com.br> writes:
> 
> > +			current->flags |= PF_MEMALLOC;
> >  			try_to_free_pages(gfp_mask);
> > +			current->flags &= ~PF_MEMALLOC;
> 
> Hm, try_to_free_pages already sets the PF_MEMALLOC flag!

Yes. Linus already pointed out this error to me
yesterday (and his latest tree should be fine).

regards,

Rik
--
Hollywood goes for world dumbination,
	Trailer at 11.

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
