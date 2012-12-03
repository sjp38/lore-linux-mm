Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 337D36B0062
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 14:07:18 -0500 (EST)
Date: Mon, 3 Dec 2012 11:07:15 -0800
From: Zach Brown <zab@redhat.com>
Subject: Re: [patch] bdi: add a user-tunable cpu_list for the bdi flusher
 threads
Message-ID: <20121203190715.GB1377@lenny.home.zabbo.net>
References: <x49boehtipu.fsf@segfault.boston.devel.redhat.com>
 <20121130221542.GM18574@lenny.home.zabbo.net>
 <x49zk1vnnju.fsf@segfault.boston.devel.redhat.com>
 <x49vccjnm0o.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49vccjnm0o.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Dec 03, 2012 at 11:22:31AM -0500, Jeff Moyer wrote:
> Jeff Moyer <jmoyer@redhat.com> writes:
> 
> >>> +		bdi->flusher_cpumask = kmalloc(sizeof(cpumask_t), GFP_KERNEL);
> >>> +		if (!bdi->flusher_cpumask)
> >>> +			return -ENOMEM;
> >>
> >> The bare GFP_KERNEL raises an eyebrow.  Some bdi_init() callers like
> >> blk_alloc_queue_node() look like they'll want to pass in a gfp_t for the
> >> allocation.
> >
> > I'd be surprised if that was necessary, seeing how every single caller
> > of blk_alloc_queue_node passes in GFP_KERNEL.  I'll make the change,
> > though, there aren't too many callers of bdi_init out there.
> 
> No other callers of bdi_init want anything but GFP_KERNEL.  In the case
> of blk_alloc_queue_node, even *it* doesn't honor the gfp_t passed in!
> Have a look at blkcg_init_queue (called from blk_alloc_queue_node) to
> see what I mean.  Maybe that's a bug?

Heh, indeed.

> I've written the patch to modify bdi_init to take a gfp_t, but I'm
> actually not in favor of this change, so I'm not going to post it
> (unless, of course, you can provide a compelling argument).  :-)

No argument here,  it just jumped out at me in the code.  I didn't check
out the callers or history of why it was that way :).

- z

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
