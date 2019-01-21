Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE058E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 14:12:14 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x15so8236697edd.2
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 11:12:14 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a12si3673497edk.106.2019.01.21.11.12.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 11:12:12 -0800 (PST)
Date: Mon, 21 Jan 2019 11:12:02 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH 6/6] drivers/IB,core: reduce scope of mmap_sem
Message-ID: <20190121191202.xygjopuuifyepd63@linux-r8p5>
References: <20190121174220.10583-1-dave@stgolabs.net>
 <20190121174220.10583-7-dave@stgolabs.net>
 <20190121183218.GK25149@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190121183218.GK25149@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dledford@redhat.com" <dledford@redhat.com>, "jack@suse.de" <jack@suse.de>, "ira.weiny@intel.com" <ira.weiny@intel.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Davidlohr Bueso <dbueso@suse.de>, willy@infradead.org

On Mon, 21 Jan 2019, Jason Gunthorpe wrote:

>On Mon, Jan 21, 2019 at 09:42:20AM -0800, Davidlohr Bueso wrote:
>> ib_umem_get() uses gup_longterm() and relies on the lock to
>> stabilze the vma_list, so we cannot really get rid of mmap_sem
>> altogether, but now that the counter is atomic, we can get of
>> some complexity that mmap_sem brings with only pinned_vm.
>>
>> Reviewed-by: Ira Weiny <ira.weiny@intel.com>
>> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
>> ---
>>  drivers/infiniband/core/umem.c | 41 ++---------------------------------------
>>  1 file changed, 2 insertions(+), 39 deletions(-)
>
>I think this addresses my comment..
>
>Considering that it is almost all infiniband, I'd rather it go it go
>through the RDMA tree with an ack from mm people? Please advise..

Yeah also Cc'ing Willy who I forgot to add for v2.

>
>Thanks,
>Jason
