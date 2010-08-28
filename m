Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A79E86B01F0
	for <linux-mm@kvack.org>; Sat, 28 Aug 2010 10:16:22 -0400 (EDT)
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <201008281558.23501.hverkuil@xs4all.nl>
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
	 <201008281508.19756.hverkuil@xs4all.nl> <1283002486.1975.3479.camel@laptop>
	 <201008281558.23501.hverkuil@xs4all.nl>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Sat, 28 Aug 2010 16:16:09 +0200
Message-ID: <1283004969.1975.3530.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Hans Verkuil <hverkuil@xs4all.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <m.nazarewicz@samsung.com>, linux-mm@kvack.org, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Jonathan Corbet <corbet@lwn.net>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Pawel Osciak <p.osciak@samsung.com>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Sat, 2010-08-28 at 15:58 +0200, Hans Verkuil wrote:
> > Isn't the proposed CMA thing vulnerable to the exact same problem? If
> > you allow sharing of regions and plug some allocator in there you get
> > the same problem. If you can solve it there, you can solve it for any
> > kind of reservation scheme.
>=20
> Since with cma you can assign a region exclusively to a driver you can en=
sure
> that this problem does not occur. Of course, if you allow sharing then yo=
u will
> end up with the same type of problem unless you know that there is only o=
ne
> driver at a time that will use that memory.

I think you could do the same thing, the proposed page allocator
solutions still needs to manage pageblock state, you can manage those
the same as you would your cma regions -- the difference is that you get
the option of letting the rest of the system use the memory in a
transparent manner if you don't need it.


> There is obviously a trade-off. I was just wondering how costly it is.
> E.g. would it be a noticeable delay making 64 MB memory available in this
> way on a, say, 600 MHz ARM.=20

Right, dunno really, rather depends on the memory bandwidth of your arm
device I suspect. It is something you'd have to test.=20

In case the machine isn't fast enough, there really isn't anything you
can do but keep the memory empty at all times; unless of course the
device in question needs it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
