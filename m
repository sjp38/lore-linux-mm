Date: Mon, 9 Sep 2002 20:53:58 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] modified segq for 2.5
In-Reply-To: <20020909233211.GI18800@holomorphy.com>
Message-ID: <Pine.LNX.4.44L.0209092052510.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@digeo.com>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Sep 2002, William Lee Irwin III wrote:
> On Mon, 9 Sep 2002, William Lee Irwin III wrote:
> >> Ideally some distinction would be nice, even if only to distinguish I/O
> >> demanded to be done directly by the workload from background writeback
> >> and/or readahead.
>
> On Mon, Sep 09, 2002 at 07:54:29PM -0300, Rik van Riel wrote:
> > OK, are we talking about page replacement or does queue scanning
> > have priority over the quality of page replacement ? ;)
>
> This is relatively tangential. The concern expressed has more to do
> with VM writeback starving workload-issued I/O than page replacement.

If that happens, the asynchronous writeback threshold should be
lower. Maybe we could even tune this dynamically ...

Compromising on page replacement is generally a Bad Idea(tm) because
page faults are expensive, very expensive.

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

Spamtraps of the month:  september@surriel.com trac@trac.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
