Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8026B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 10:57:56 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 4so11358888itv.4
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 07:57:56 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x6sor3492373itd.86.2017.09.25.07.57.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Sep 2017 07:57:55 -0700 (PDT)
Subject: Re: [PATCH 4/7] page-writeback: pass in '0' for nr_pages writeback in
 laptop mode
References: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
 <1505921582-26709-5-git-send-email-axboe@kernel.dk>
 <20170921145929.GD8839@infradead.org>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <d0120f9e-9b52-9e42-7f1d-57e00ee12c3a@kernel.dk>
Date: Mon, 25 Sep 2017 08:57:52 -0600
MIME-Version: 1.0
In-Reply-To: <20170921145929.GD8839@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, clm@fb.com, jack@suse.cz

On 09/21/2017 08:59 AM, Christoph Hellwig wrote:
> On Wed, Sep 20, 2017 at 09:32:59AM -0600, Jens Axboe wrote:
>> Laptop mode really wants to writeback the number of dirty
>> pages and inodes. Instead of calculating this in the caller,
>> just pass in 0 and let wakeup_flusher_threads() handle it.
>>
>> Use the new wakeup_flusher_threads_bdi() instead of rolling
>> our own. This changes the writeback to not be range cyclic,
>> but that should not matter for laptop mode flush-all
>> semantics.
> 
> Looks good,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
> While we're at sorting out the laptop_mode_wb_timer mess:
> can we move initializing and deleting it from the block code
> to the backing-dev code given that it now doesn't assume anything
> about block devices any more?

Good point, I'll include that in a followup for 4.15.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
