Date: Wed, 24 Jul 2002 23:35:27 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: page_add/remove_rmap costs
In-Reply-To: <3D3F0DE4.84A4FB62@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207242334460.3086-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jul 2002, Andrew Morton wrote:
> Rik van Riel wrote:
> > On Wed, 24 Jul 2002, Andrew Morton wrote:
> >
> > I guess I'll take a stab at bcrl's and davem's code and will
> > try to also hide it between an rmap.c interface ;)
>
> hmm, OK.  Big job...

Absolutely, not a short term thing.  In the short term
I'll split out the remainder of Craig Kulesa's big patch
and will send you bits and pieces.

> > > For example: given that copy_page_range performs atomic ops against
> > > page->count, how come page_add_rmap()'s atomic op against page->flags
> > > is more of a problem?
> >
> > Could it have something to do with cpu_relax() delaying
> > things ?
>
> Don't think so.  That's only executed on the contended case,

You're right.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
