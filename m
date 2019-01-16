Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4865D8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 11:00:39 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id s50so2535682edd.11
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:00:39 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t8-v6si1252754ejz.295.2019.01.16.08.00.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 08:00:37 -0800 (PST)
Date: Wed, 16 Jan 2019 08:00:26 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH 6/6] drivers/IB,core: reduce scope of mmap_sem
Message-ID: <20190116160026.iyg7pwmzy5o35h5l@linux-r8p5>
References: <20190115181300.27547-1-dave@stgolabs.net>
 <20190115181300.27547-7-dave@stgolabs.net>
 <20190115205311.GD22031@mellanox.com>
 <20190115211207.GD6310@bombadil.infradead.org>
 <20190115211722.GA3758@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190115211722.GA3758@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Matthew Wilcox <willy@infradead.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Davidlohr Bueso <dbueso@suse.de>

On Tue, 15 Jan 2019, Jason Gunthorpe wrote:

>On Tue, Jan 15, 2019 at 01:12:07PM -0800, Matthew Wilcox wrote:
>> On Tue, Jan 15, 2019 at 08:53:16PM +0000, Jason Gunthorpe wrote:
>> > > -	new_pinned = atomic_long_read(&mm->pinned_vm) + npages;
>> > > +	new_pinned = atomic_long_add_return(npages, &mm->pinned_vm);
>> > >  	if (new_pinned > lock_limit && !capable(CAP_IPC_LOCK)) {
>> >
>> > I thought a patch had been made for this to use check_overflow...
>>
>> That got removed again by patch 1 ...
>
>Well, that sure needs a lot more explanation. :(

What if we just make the counter atomic64?

Thanks,
Davidlohr
