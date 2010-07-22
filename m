Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 783046B02A8
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 06:17:49 -0400 (EDT)
Date: Thu, 22 Jul 2010 19:17:42 +0900
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <op.vf8oa80k7p4s8u@pikus>
References: <000001cb296f$6eba8fa0$4c2faee0$%szyprowski@samsung.com>
	<20100722183432U.fujita.tomonori@lab.ntt.co.jp>
	<op.vf8oa80k7p4s8u@pikus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20100722191658V.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: m.nazarewicz@samsung.com
Cc: m.szyprowski@samsung.com, fujita.tomonori@lab.ntt.co.jp, corbet@lwn.net, linux-mm@kvack.org, p.osciak@samsung.com, xiaolin.zhang@intel.com, hvaibhav@ti.com, robert.fekete@stericsson.com, marcus.xm.lorentzon@stericsson.com, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jul 2010 11:50:58 +0200
**UNKNOWN CHARSET** <m.nazarewicz@samsung.com> wrote:

> On Thu, 22 Jul 2010 11:35:07 +0200, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:
> > You have the feature in the wrong place.
> >
> > Your example: a camera driver and a video driver can share 20MB, then
> > they want 20MB exclusively.
> >
> > You can reserve 20MB and make them share it. Then you can reserve 20MB
> > for both exclusively.
> >
> > You know how the whole system works. Adjust drivers (probably, with
> > module parameters).
> 
> So you are talking about moving complexity from the CMA core to the drivers.

I don't think that adjusting some drivers about how they use memory is
so complicated. Just about how much and exclusive or share.

And adjusting drivers in embedded systems is necessary anyway.

It's too complicated feature that isn't useful for the majority.


> > When a video driver needs 20MB to work properly, what's the point of
> > releasing the 20MB for others then trying to get it again later?
> 
> If you have a video driver that needs 20MiB and a camera that needs 20MiB
> will you reserve 40MiB total? That's 20MiB wasted if on your system those
> two can never work at the same time. So do you reserve 20MiB and share?
> That won't work if on your system the two can work at the same time.
> 
> With CMA you can configure the kernel for both cases.

See above. You can do without such complicated framework.


> Lost you there...  If something does not make sense on your system you
> don't configure CMA to do that. That's one of the points of CMA.  What
> does not make sense on your platform may make perfect sense on some
> other system, with some other drivers maybe.

What's your point? The majority of features (e.g. scsi, ata, whatever)
works in that way. They are useful on some and not on some.

Are you saying, "my system needs this feature. You can disable it if
you don't need it. so let's merge it. it doesn't break your system."?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
