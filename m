Date: Mon, 25 Sep 2000 01:41:37 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000925014137.B6249@athlon.random>
References: <20000924231240.D5571@athlon.random> <Pine.LNX.4.21.0009242310510.8705-100000@elte.hu> <20000924224303.C2615@redhat.com> <20000925001342.I5571@athlon.random> <20000925003650.A20748@home.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925003650.A20748@home.ds9a.nl>; from ahu@ds9a.nl on Mon, Sep 25, 2000 at 12:36:50AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 12:36:50AM +0200, bert hubert wrote:
> True. But they also appear to be found and solved at an impressive rate.

We're talking about shrink_[id]cache_memory change. That have _nothing_ to do
with the VM changes that happened anywhere between test8 and test9-pre6.

You were talking about a different thing.

> It's tempting to revert the merge, but let's work at it a bit longer. There

Since you're talking about this I'll soon (as soon as I'll finish some other
thing that is just work in progress) release a classzone against latest's
2.4.x. My approch is _quite_ different from the curren VM. Current approch is
very imperfect and it's based solely on aging whereas classzone had hooks into
pagefaults paths and all other map/unmap points to have perfect accounting of
the amount of active/inactive stuff. The mapped pages was never seen by
anything except swap_out, if they was mapped (it's not a if page->age then move
into the active list, with classzone the page was _just_ in the active list in
first place since it was mapped).

I consider the current approch the wrong way to go and for this reason I prefer
to spend time porting/improving classzone.

In classzone the aging exists too but it's _completly_ orthogonal to how rest
of the VM works. classzone had only 1 bit of aging per page to save mem_map_t
array so I'll extend the aging info from 1 bit to 32bit to make it more biased.

This is my humble opinion at least. I may be wrong. I'll let you know
once I'll have a patch I'll happy with and some real life number to proof my
theory.

In the meantime if you want to go back to 2.4.0-test1-ac22-class++ to give it a
try under swap to see the difference in the behaviour and compare (Mike said
it's still an order of magnitude faster with his "make -j30 bzImage" testcase
and he's always very reliable in his reports).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
