Date: Mon, 13 May 2002 12:08:09 -0400 (EDT)
From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [RFC][PATCH] IO wait accounting
In-Reply-To: <87bsbl9ogw.fsf@atlas.iskon.hr>
Message-ID: <Pine.LNX.3.96.1020513120027.27042A-100000@gatekeeper.tmr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko.calusic@iskon.hr>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 12 May 2002, Zlatko Calusic wrote:

> Rik van Riel <riel@conectiva.com.br> writes:
> >
> > And should we measure read() waits as well as page faults or
> > just page faults ?
> >
> 
> Definitely both. Somewhere on the web was a nice document explaining
> how Solaris measures iowait%, I read it few years ago and it was a
> great stuff (quite nice explanation).

  I'm out of town so I miss a bit of this, but I agree, what you want time
waiting for IO, total.

  That said, it would probably be useful to keep the first patch
information, since overall disk performance reflects in total IOwait,
while wait VM is useful comparing the several flavors of vm tuning and
enhancement, bot the the implementors and the users, who may have unusual
configurations.

  I hope that write blocks are falling into place as well, because even
though they are less common, you still get programs which build ugly stuff
like a full 700MB CD image in memory and do that last write (or close, or
fsync, etc). This is bad with large memory, and unspeakable with small,
where stuff is being paged in and writen out.

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
