Subject: Re: Comment on patch to remove nr_async_pages limit
References: <Pine.LNX.4.33.0106050820540.867-100000@mikeg.weiden.de>
Reply-To: zlatko.calusic@iskon.hr
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
Date: 05 Jun 2001 17:57:45 +0200
In-Reply-To: <Pine.LNX.4.33.0106050820540.867-100000@mikeg.weiden.de> (Mike Galbraith's message of "Tue, 5 Jun 2001 09:38:08 +0200 (CEST)")
Message-ID: <873d9ezzpi.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@wen-online.de>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mike Galbraith <mikeg@wen-online.de> writes:

> On Mon, 4 Jun 2001, Marcelo Tosatti wrote:
> 
> > Zlatko,
> >
> > I've read your patch to remove nr_async_pages limit while reading an
> > archive on the web. (I have to figure out why lkml is not being delivered
> > correctly to me...)
> >
> > Quoting your message:
> >
> > "That artificial limit hurts both swap out and swap in path as it
> > introduces synchronization points (and/or weakens swapin readahead),
> > which I think are not necessary."
> >
> > If we are under low memory, we cannot simply writeout a whole bunch of
> > swap data. Remember the writeout operations will potentially allocate
> > buffer_head's for the swapcache pages before doing real IO, which takes
> > _more memory_: OOM deadlock.
> 
> What's the point of creating swapcache pages, and then avoiding doing
> the IO until it becomes _dangerous_ to do so?  That's what we're doing
> right now.  This is a problem because we guarantee it will become one.
> We guarantee that the pagecache will become almost pure swapcache by
> delaying the writeout so long that everything else is consumed.
> 

Huh, this looks just like my argument, just put in different words. I
should have read this sooner. :)
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
