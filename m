Date: Sun, 20 May 2001 10:08:04 +0200 (CEST)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: [RFC][PATCH] Re: Linux 2.4.4-ac10
In-Reply-To: <Pine.LNX.4.33.0105200339150.23366-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.33.0105200957500.323-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 20 May 2001, Rik van Riel wrote:

> On Sun, 20 May 2001, Mike Galbraith wrote:
> >
> > I'm not sure why that helps.  I didn't put it in as a trick or
> > anything though.  I put it in because it didn't seem like a
> > good idea to ever have more cleaned pages than free pages at a
> > time when we're yammering for help.. so I did that and it helped.
>        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>
> Note that this is not the normal situation. Now think
> about the amount of data you'd be blowing away from the
> inactive_clean pages after a bit of background aging
> has gone on on a lightly loaded system.  Not Good(tm)

You're right.  It should never dump too much data at once.  OTOH, if
those cleaned pages are really old (front of reclaim list), there's no
value in keeping them either.  Maybe there should be a slow bleed for
mostly idle or lightly loaded conditions.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
