Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CBDA26B0207
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 03:06:39 -0400 (EDT)
Date: Fri, 2 Apr 2010 09:06:29 +0200
From: Daniel Mack <daniel@caiaq.de>
Subject: Re: [Question] race condition in mm/page_alloc.c regarding
 page->lru?
Message-ID: <20100402070629.GT30801@buzzloop.caiaq.de>
References: <i2i5f4a33681003312105m4cd42e9ayfe35cc0988c401b6@mail.gmail.com>
 <g2g5f4a33681004012051wedea9538w9da89e210b731422@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <g2g5f4a33681004012051wedea9538w9da89e210b731422@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: TAO HU <tghk48@motorola.com>
Cc: linux-mm@kvack.org, Chang Qing-A21550 <Qing.Chang@motorola.com>, "Ye Yuan.Bo-A22116" <yuan-bo.ye@motorola.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 02, 2010 at 11:51:33AM +0800, TAO HU wrote:
> On Thu, Apr 1, 2010 at 12:05 PM, TAO HU <tghk48@motorola.com> wrote:
> > We got a panic on our ARM (OMAP) based HW.
> > Our code is based on 2.6.29 kernel (last commit for mm/page_alloc.c is
> > cc2559bccc72767cb446f79b071d96c30c26439b)
> >
> > It appears to crash while going through pcp->list in
> > buffered_rmqueue() of mm/page_alloc.c after checking vmlinux.
> > "00100100" implies LIST_POISON1 that suggests a race condition between
> > list_add() and list_del() in my personal view.
> > However we not yet figure out locking problem regarding page.lru.

I'm sure this is just a memory corruption which is unrelated to code in
the the memory management area. The code there just happens to trigger
it as it is called frequently and is very sensitive to bogus data

Did you see the other thread I started off yesterday?

  http://lkml.indiana.edu/hypermail/linux/kernel/1004.0/00157.html

We could well see the same problem here. Not sure though as any kind of
memory corruption ends up in Ooopses like the ones you see, but it could
be a hint.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
