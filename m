Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 19C8D8E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 11:00:35 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id x5-v6so21727122ioa.6
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 08:00:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v66-v6sor16088407ioe.128.2018.09.21.08.00.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Sep 2018 08:00:33 -0700 (PDT)
Subject: Re: block: DMA alignment of IO buffer allocated from slab
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
 <20180920063129.GB12913@lst.de> <87h8ij0zot.fsf@vitty.brq.redhat.com>
 <20180921130504.GA22551@lst.de>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <98996e39-7d29-354c-9009-d4b1a1bbdeb0@kernel.dk>
Date: Fri, 21 Sep 2018 09:00:31 -0600
MIME-Version: 1.0
In-Reply-To: <20180921130504.GA22551@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ming Lei <ming.lei@redhat.com>, Christoph Lameter <cl@linux.com>

On 9/21/18 7:05 AM, Christoph Hellwig wrote:
> On Fri, Sep 21, 2018 at 03:04:18PM +0200, Vitaly Kuznetsov wrote:
>> Christoph Hellwig <hch@lst.de> writes:
>>
>>> On Wed, Sep 19, 2018 at 05:15:43PM +0800, Ming Lei wrote:
>>>> 1) does kmalloc-N slab guarantee to return N-byte aligned buffer?  If
>>>> yes, is it a stable rule?
>>>
>>> This is the assumption in a lot of the kernel, so I think if somethings
>>> breaks this we are in a lot of pain.
>>
>> It seems that SLUB debug breaks this assumption. Kernel built with
>>
>> CONFIG_SLUB_DEBUG=y
>> CONFIG_SLUB=y
>> CONFIG_SLUB_DEBUG_ON=y
> 
> Looks like we should fix SLUB debug then..

Fully agree, it's such a fundamental property.

-- 
Jens Axboe
