Date: Tue, 3 Dec 2002 11:58:54 -0800
From: The One True Dave Barry <dave@zork.net>
Subject: Re: [PATCH] 2.4.20-rmap15a
Message-ID: <20021203195854.GA6709@zork.net>
References: <Pine.LNX.4.44L.0212011833310.15981-100000@imladris.surriel.com> <6usmxfys45.fsf@zork.zork.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6usmxfys45.fsf@zork.zork.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: sneakums@zork.net
List-ID: <linux-mm.kvack.org>

Quothe Sean Neakums <sneakums@zork.net>, on Tue, Dec 03, 2002:
> Dave Barry, another
> lnx-bbc developer, has observed something similar.  The difference in
> system times seems to be above noise, too.  Both of the kernels I used
> also had Stephen Tweedie's ext3 updates for 2.4.20 applied[0].  I can
> retest without, if you wish.  I believe Dave's kernels had only rmap
> applied, however.

	This is correct, and believe it or not i'm even using
	2.4.19 + rmap15a, no other patches.  I don't have my hard
	numbers available, but the difference between builds was quite
	significant, something like:

	2.4.19 vanilla:
	real 85m

	2.4.19-rmap15a:
	real 102m

> I used ccache with these builds and they are almost entirely cached
> (the big exception being gcc), so the job becomes fairly I/O-bound as
> a result.  The builds are quite big: the CVS tree unpacks and builds
> about three hundred megabytes of source, resulting in a build
> footprint of approximately 2.9GiB.  

	This applies to me as well.

>The volume I used for the build is
> formatted as ext3, with htree activated.  

	My build volume is formatted ext3, no htree.

-- 
=================-------------------------------=========================
| Dave Barry	| All the freaky people make	| dave@zork.net         |
| ...  		| the beauty of the world.	| http://psax.org/~dave |
|		|	--Michael Franti	|			|
=================-------------------------------=========================
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
