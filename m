Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: 2.4.8/2.4.9 VM problems
Date: Mon, 20 Aug 2001 22:13:08 +0200
References: <Pine.LNX.4.33L.0108201402140.31410-100000@duckman.distro.conectiva>
In-Reply-To: <Pine.LNX.4.33L.0108201402140.31410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <20010820200639Z16342-32383+579@humbolt.nl.linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Benjamin Redelings I <bredelin@ucla.edu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On August 20, 2001 07:02 pm, Rik van Riel wrote:
> On Mon, 20 Aug 2001, Benjamin Redelings I wrote:
> 
> > Was it really true, that swapped in pages didn't get marked as
> > referenced before?
> 
> That's just an artifact of the use-once patch, which
> only sets the referenced bit on the _second_ access
> to a page.

It was an artifact of the change in lru_cache_add where all new pages start 
on the inactive queue instead of the active queue.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
