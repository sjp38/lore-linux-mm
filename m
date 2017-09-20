Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 269F86B0033
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 11:18:52 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id d6so4466252itc.6
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 08:18:52 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d22sor784786ioj.81.2017.09.20.08.18.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 08:18:50 -0700 (PDT)
Subject: Re: [PATCH 1/6] buffer: cleanup free_more_memory() flusher wakeup
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
 <1505850787-18311-2-git-send-email-axboe@kernel.dk>
 <20170920141727.GB11106@quack2.suse.cz>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <cd7a0ac4-7cc7-41b3-1712-69226256ef36@kernel.dk>
Date: Wed, 20 Sep 2017 09:18:47 -0600
MIME-Version: 1.0
In-Reply-To: <20170920141727.GB11106@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, clm@fb.com

On 09/20/2017 08:17 AM, Jan Kara wrote:
> On Tue 19-09-17 13:53:02, Jens Axboe wrote:
>> This whole function is... interesting. Change the wakeup call
>> to the flusher threads to pass in nr_pages == 0, instead of
>> some random number of pages. This matches more closely what
>> similar cases do for memory shortage/reclaim.
>>
>> Signed-off-by: Jens Axboe <axboe@kernel.dk>
> 
> Ok, probably makes sense. You can add:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> 
> BTW, after this nobody seems to use the number of pages for
> wakeup_flusher_threads() so can you just delete the argument for the
> function? After all system-wide wakeup is useful only for system wide
> sync(2) or memory reclaim so number of pages isn't very useful...

Great observation! That's true, and if we kill that, it enables
further cleanups down the line for patch 5 and 6. I have
incorporated that.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
