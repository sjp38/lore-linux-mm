Date: Fri, 28 Oct 2005 03:10:45 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-ID: <20051028011045.GD5091@opteron.random>
References: <20051027131725.GI5091@opteron.random> <1130425212.23729.55.camel@localhost.localdomain> <20051027151123.GO5091@opteron.random> <20051027112054.10e945ae.akpm@osdl.org> <20051027200434.GT5091@opteron.random> <20051027135058.2f72e706.akpm@osdl.org> <20051027213721.GX5091@opteron.random> <20051027152340.5e3ae2c6.akpm@osdl.org> <20051028002231.GC5091@opteron.random> <20051027173243.41ecd335.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051027173243.41ecd335.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: pbadari@us.ibm.com, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 27, 2005 at 05:32:43PM -0700, Andrew Morton wrote:
> hm, so we have a somewhat awkward interface to a very specific thing to
> benefit a closed-source app.  That'll go down well ;)

I know. Many of the database features have benefited closed-source apps
first and only later they have the potential to benefit everything else
too. As far as I don't have to run the closed-source apps myself I'm ok.

Plus the fact Badari also came up with a virtual-range interface with
its first MADV_DISCARD patch makes me suspect they'll also have a
benefit for similar reasons compared to the fs interface.

> what - MADV_REMOVE?

No problem with the name change.

> I think it'll need to return -EINVAL for nonlinear vma's?

That would be fine. For tmpfs it may not be too difficult to free the
swap even when the page offsets are sparse. For real fs it would be more
tricky to support many tiny holes. But the real reason I think -EINVAL
is ok, is that I generally dislike nonlinear related complexity because
I dislike nonlinear in the first place (nonlinear avoids vma overhead at
the expense of screwing up paging scalability, it should be used only in
extreme cases were the mapping is mlocked anyway).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
