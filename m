Date: Sun, 20 May 2001 16:32:59 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [RFC][PATCH] Re: Linux 2.4.4-ac10
In-Reply-To: <Pine.LNX.4.33.0105201943510.1635-100000@mikeg.weiden.de>
Message-ID: <Pine.LNX.4.21.0105201626190.5547-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@wen-online.de>
Cc: Zlatko Calusic <zlatko.calusic@iskon.hr>, "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sun, 20 May 2001, Mike Galbraith wrote:

> > Also in all recent kernels, if the machine is swapping, swap cache
> > grows without limits and is hard to recycle, but then again that is
> > a known problem.
> 
> This one bugs me.  I do not see that and can't understand why.

To throw away dirty and dead swapcache (its done at swap writepage())
pages page_launder() has to run into its second loop (launder_loop = 1)
(meaning that a lot of clean cache has been thrown out already).

We can "short circuit" this dead swapcache pages by cleaning them in the
first page_launder() loop.

Take a look at the writepage() patch I sent to Linus a few days ago.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
