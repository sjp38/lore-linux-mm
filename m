Date: Sun, 22 Sep 2002 02:04:04 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: overcommit stuff
In-Reply-To: <16785326.1032628095@[10.10.2.3]>
Message-ID: <Pine.LNX.4.44.0209220151030.2448-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@digeo.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 21 Sep 2002, Martin J. Bligh wrote:
> 
> > The usual tricks for amortising this counter's cost have (serious)
> > accuracy implications.
> 
> Well, seems it's a rough guess anyway ... at least it's vastly
> inaccurate in one direction (pessimistic).

Yesss.  I don't think it matters much if it's somewhat inaccurate
(the half-of-memory thing is just pulled out of a hat anyway, isn't
it? and there's no accounting for taste^Hthe kernel's memory usage,
just a hope that it won't go over half).

But it would be very wrong to introduce any indeterminacy in the
calculations, such that the numbers might progressively drift
further and further away from what's right.  That's one of the
reasons it ends up so pessimistic, because it would be impossible
(or too costly) to do the accounting otherwise.

> I was thinking of moving the update in vm_enough_memory under
> the switch for what type of overcommit you had, and doing something
> similar for the other places it's updated. I suppose that would do
> unfortunate things if you turned overcommit from 1 to something
> else whilst the system was running though ... not convinced that's
> a good idea anyway OTOH.

It is intended that you should be able to switch commit modes while
running.  There is one hole there that we've not got around to
plugging yet, the handling of MAP_NORESERVE, but otherwise I believe
it makes sense: please don't take that away.

I like to see those Committed_AS numbers (though I don't care for
the "_AS" prefix), even though I run loose.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
