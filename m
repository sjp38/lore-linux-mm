Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 6ADFA6B0062
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 11:22:35 -0500 (EST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [patch] bdi: add a user-tunable cpu_list for the bdi flusher threads
References: <x49boehtipu.fsf@segfault.boston.devel.redhat.com>
	<20121130221542.GM18574@lenny.home.zabbo.net>
	<x49zk1vnnju.fsf@segfault.boston.devel.redhat.com>
Date: Mon, 03 Dec 2012 11:22:31 -0500
In-Reply-To: <x49zk1vnnju.fsf@segfault.boston.devel.redhat.com> (Jeff Moyer's
	message of "Mon, 03 Dec 2012 10:49:25 -0500")
Message-ID: <x49vccjnm0o.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zach Brown <zab@redhat.com>
Cc: Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Jeff Moyer <jmoyer@redhat.com> writes:

>>> +		bdi->flusher_cpumask = kmalloc(sizeof(cpumask_t), GFP_KERNEL);
>>> +		if (!bdi->flusher_cpumask)
>>> +			return -ENOMEM;
>>
>> The bare GFP_KERNEL raises an eyebrow.  Some bdi_init() callers like
>> blk_alloc_queue_node() look like they'll want to pass in a gfp_t for the
>> allocation.
>
> I'd be surprised if that was necessary, seeing how every single caller
> of blk_alloc_queue_node passes in GFP_KERNEL.  I'll make the change,
> though, there aren't too many callers of bdi_init out there.

No other callers of bdi_init want anything but GFP_KERNEL.  In the case
of blk_alloc_queue_node, even *it* doesn't honor the gfp_t passed in!
Have a look at blkcg_init_queue (called from blk_alloc_queue_node) to
see what I mean.  Maybe that's a bug?

I've written the patch to modify bdi_init to take a gfp_t, but I'm
actually not in favor of this change, so I'm not going to post it
(unless, of course, you can provide a compelling argument).  :-)

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
