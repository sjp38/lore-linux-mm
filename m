Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 540C96B02B4
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 11:38:11 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id k82so11470488oih.1
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 08:38:11 -0700 (PDT)
Received: from mail-it0-x229.google.com (mail-it0-x229.google.com. [2607:f8b0:4001:c0b::229])
        by mx.google.com with ESMTPS id t187si4752034oih.434.2017.08.14.08.38.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 08:38:10 -0700 (PDT)
Received: by mail-it0-x229.google.com with SMTP id m34so19830763iti.1
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 08:38:10 -0700 (PDT)
Subject: Re: [PATCH v1 2/6] fs: use on-stack-bio if backing device has
 BDI_CAP_SYNC capability
References: <20170809023122.GF31390@bombadil.infradead.org>
 <20170809024150.GA32471@bbox> <20170810030433.GG31390@bombadil.infradead.org>
 <CAA9_cmekE9_PYmNnVmiOkyH2gq5o8=uvEKnAbMWw5nBX-zE69g@mail.gmail.com>
 <20170811104615.GA14397@lst.de>
 <20c5b30a-b787-1f46-f997-7542a87033f8@kernel.dk>
 <20170814085042.GG26913@bbox>
 <51f7472a-977b-be69-2688-48f2a0fa6fb3@kernel.dk>
 <20170814150620.GA12657@bgram>
 <51893dc5-05a3-629a-3b88-ecd8e25165d0@kernel.dk>
 <20170814153059.GA13497@bgram>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <0c83e7af-10a4-3462-bb4c-4254adcf6f7a@kernel.dk>
Date: Mon, 14 Aug 2017 09:38:06 -0600
MIME-Version: 1.0
In-Reply-To: <20170814153059.GA13497@bgram>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Vishal Verma <vishal.l.verma@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, kernel-team <kernel-team@lge.com>

On 08/14/2017 09:31 AM, Minchan Kim wrote:
>> Secondly, generally you don't have slow devices and fast devices
>> intermingled when running workloads. That's the rare case.
> 
> Not true. zRam is really popular swap for embedded devices where
> one of low cost product has a really poor slow nand compared to
> lz4/lzo [de]comression.

I guess that's true for some cases. But as I said earlier, the recycling
really doesn't care about this at all. They can happily coexist, and not
step on each others toes.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
