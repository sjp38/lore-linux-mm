Date: Mon, 21 May 2001 05:44:13 +0200 (CEST)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: [RFC][PATCH] Re: Linux 2.4.4-ac10
In-Reply-To: <Pine.LNX.4.21.0105201837240.5531-100000@imladris.rielhome.conectiva>
Message-ID: <Pine.LNX.4.33.0105210538510.465-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Zlatko Calusic <zlatko.calusic@iskon.hr>, "Stephen C. Tweedie" <sct@redhat.com>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 20 May 2001, Rik van Riel wrote:

> On Sun, 20 May 2001, Mike Galbraith wrote:
> > On 20 May 2001, Zlatko Calusic wrote:
>
> > > Also in all recent kernels, if the machine is swapping, swap cache
> > > grows without limits and is hard to recycle, but then again that is
> > > a known problem.
> >
> > This one bugs me.  I do not see that and can't understand why.
>
> Could it be because we never free swap space and never
> delete pages from the swap cache ?

I sent a query to the list asking if a heavy load cleared it out,
but got no replies.  I figured about the only thing it could be
is that under light load, reclaim isn't needed to cure and shortage.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
