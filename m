Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 4FA306B00EC
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 09:56:00 -0400 (EDT)
Date: Mon, 16 Apr 2012 08:55:57 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: how to avoid allocating or freeze MOVABLE memory in userspace
In-Reply-To: <CAN1soZyQuiYU_1f0G0eDqF-9WwzjgSgmr3QBh8cpkF+r1r7HrA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1204160853530.7726@router.home>
References: <CAN1soZzEuhQQYf7fNqOeMYT3Z-8VMix+1ihD77Bjtf+Do3x3DA@mail.gmail.com> <alpine.DEB.2.00.1204131326170.15905@router.home> <CAN1soZyQuiYU_1f0G0eDqF-9WwzjgSgmr3QBh8cpkF+r1r7HrA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haojian Zhuang <haojian.zhuang@gmail.com>
Cc: linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, m.szyprowski@samsung.com

On Sat, 14 Apr 2012, Haojian Zhuang wrote:

> On Sat, Apr 14, 2012 at 2:27 AM, Christoph Lameter <cl@linux.com> wrote:
> > On Fri, 13 Apr 2012, Haojian Zhuang wrote:
> >
> >> I have one question on memory migration. As we know, malloc() from
> >> user app will allocate MIGRATE_MOVABLE pages. But if we want to use
> >> this memory as DMA usage, we can't accept MIGRATE_MOVABLE type. Could
> >> we change its behavior before DMA working?
> >
> > MIGRATE_MOVABLE works fine for DMA. If you keep a reference from a device
> > driver to user pages then you will have to increase the page refcount
> > which will in turn pin the page and make it non movable for as long as you
> > keep the refcount.
>
> Hi Christoph,
>
> Thanks for your illustration. But it's a little abstract. Could you
> give me a simple example
> or show me the code?

Run get_user_pages() on the memory you are interest in pinning. See how
other drivers do that by looking up other use cases. F.e. ib_umem_get()
does a similar thing.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
