Date: Fri, 8 Jun 2001 22:52:18 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: VM tuning patch, take 2
In-Reply-To: <Pine.LNX.4.21.0106090017170.10415-100000@imladris.rielhome.conectiva>
Message-ID: <Pine.LNX.4.21.0106082248320.3343-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Jonathan Morton <chromi@cyberspace.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sat, 9 Jun 2001, Rik van Riel wrote:

<snip>

> I have a similar patch which makes processes wait on IO completion
> when they find too many dirty pages on the inactive_dirty list ;)

If we ever want to make that PageLaunder thing reality (well, if we realy
want a decent VM we _need_ that) we need to make the accouting on a
buffer_head basis and decrease the amount of data being written out to
disk at end_buffer_io_sync(). 

The reason is write() --- its impossible to account for pages written
via write(). 

:( 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
