Date: Mon, 23 Oct 2000 18:36:49 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Another wish item for your TODO list...
Message-ID: <20001023183649.H2772@redhat.com>
References: <20001023175402.B2772@redhat.com> <Pine.LNX.4.21.0010231501210.13115-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010231501210.13115-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Oct 23, 2000 at 03:02:06PM -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Oct 23, 2000 at 03:02:06PM -0200, Rik van Riel wrote:
> 
> > Just a quick thought --- at some point it would be good if we
> > could add logic to the core VM so that for sequentially accessed
> > files, reclaiming any page of the file from cache would evict
> > the _whole_ of the file from cache.
> 
> I take it you mean "move all the pages from before the
> currently read page to the inactive list", so we preserve
> the pages we just read in with readahead ?

No, I mean that once we actually remove a page, we should also remove
all the other pages IF the file has never been accessed in a
non-sequential manner.  The inactive management is separate.

It's an optimisation in CPU time as much as for anything else: there's
just no point in doing expensive memory balancing/aging for pages
which we know are next to useless.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
