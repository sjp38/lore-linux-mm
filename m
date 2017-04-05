Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id D00156B03A1
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 01:13:25 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id l65so401895vkd.11
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 22:13:25 -0700 (PDT)
Received: from mail-vk0-x233.google.com (mail-vk0-x233.google.com. [2607:f8b0:400c:c05::233])
        by mx.google.com with ESMTPS id r3si8282884vkf.126.2017.04.04.22.13.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 22:13:25 -0700 (PDT)
Received: by mail-vk0-x233.google.com with SMTP id d188so1333022vka.0
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 22:13:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <8760ijiind.fsf@notabene.neil.brown.name>
References: <871staffus.fsf@notabene.neil.brown.name> <20170404071033.GA25855@infradead.org>
 <8760ijiind.fsf@notabene.neil.brown.name>
From: Ming Lei <tom.leiming@gmail.com>
Date: Wed, 5 Apr 2017 13:13:23 +0800
Message-ID: <CACVXFVN8tTYjidbdSJsEpnWcUccvyd-xsvCpJ9vDMtvs+ciCzQ@mail.gmail.com>
Subject: Re: [PATCH] loop: Add PF_LESS_THROTTLE to block/loop device thread.
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@fb.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 5, 2017 at 12:27 PM, NeilBrown <neilb@suse.com> wrote:
> On Tue, Apr 04 2017, Christoph Hellwig wrote:
>
>> Looks fine,
>>
>> Reviewed-by: Christoph Hellwig <hch@lst.de>
>>
>> But if you actually care about performance in any way I'd suggest
>> to use the loop device in direct I/O mode..
>
> The losetup on my test VM is too old to support that :-(
> I guess it might be time to upgraded.
>
> It seems that there is not "mount -o direct_loop" or similar, so you
> have to do the losetup and the mount separately.  Any thoughts on

I guess the 'direct_loop' can be added into 'mount' directly? but not familiar
with mount utility.

> whether that should be changed ?

There was sysfs interface for controling direct IO in the initial
submission, but
looks it was reviewed out, :-)


Thanks,
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
