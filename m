Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id A25A938CE7
	for <linux-mm@kvack.org>; Thu, 23 Aug 2001 16:03:54 -0300 (EST)
Date: Thu, 23 Aug 2001 16:03:35 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH NG] alloc_pages_limit & pages_min
In-Reply-To: <200108231856.f7NIuhv12558@mailg.telia.com>
Message-ID: <Pine.LNX.4.33L.0108231600020.31410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Aug 2001, Roger Larsson wrote:
> On Thursdayen den 23 August 2001 20:44, Rik van Riel wrote:
> > On Thu, 23 Aug 2001, Roger Larsson wrote:
> > > f we did get one page => we are above pages_min
> > > try to reach pages_low too.
> >
> > Yeah, but WHY ?
>
> * Historic reasons - I feel good at that limit... :-)
>  MIN the limit never crossed

Never crossed by (free + clean) pages. I see no reason why
we couldn't leave the free-only target at this limit...

>  LOW center, our target of free pages - when all zones time to free.

Meaning we'll usually not have any clean pages around but
only free pages if your patch gets applied ;)

>  HIGH limit were to stop the freeing.

Rik
--
IA64: a worthy successor to the i860.

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
