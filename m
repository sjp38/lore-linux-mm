Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [PATCH] kill flush_dirty_buffers
Date: Mon, 6 Aug 2001 21:53:34 +0200
References: <Pine.LNX.4.33L.0108061538360.1439-100000@duckman.distro.conectiva>
In-Reply-To: <Pine.LNX.4.33L.0108061538360.1439-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Message-Id: <0108062153340J.00294@starship>
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>
Cc: Chris Mason <mason@suse.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 06 August 2001 20:39, Rik van Riel wrote:
> On Mon, 6 Aug 2001, Linus Torvalds wrote:
> > The other issue is that I suspect that "flushtime" is completely
> > useless these days, and should just be dropped. If we've decided to
> > start flushing stuff out, we shouldn't stop flushing just because
> > some buffer hasn't quite reached the proper age yet.

It's still useful for making sure dirty buffers don't get too old.

> > We'd have been
> > better off maybe deciding not to even _start_ flushing at all, but
> > once we've started, we might as well do the dirty buffers we see (up
> > to a maximum that is due to IO _latency_, not due to "how long since
> > this buffer was dirtied")

*nod*

Where IO latency isn't that well defined at the moment.  Consider a a 
slow and a fast writable block device on the same system.  The ideal 
length of the IO queue depends on which has most of the IO activity.

This suggests that buffer flushing needs to be per-device.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
