Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id AEA446B02EE
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 16:17:12 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id u2so12914769itb.7
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 13:17:12 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a64sor3885335iog.208.2017.09.11.13.17.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Sep 2017 13:17:11 -0700 (PDT)
Subject: Re: [PATCH] mm/backing-dev.c: fix an error handling path in
 'cgwb_create()'
References: <20170911194323.17833-1-christophe.jaillet@wanadoo.fr>
 <20170911201506.GA15044@quack2.suse.cz>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <a0163559-d867-d8e0-d84d-bc99f6f4c43d@kernel.dk>
Date: Mon, 11 Sep 2017 14:17:09 -0600
MIME-Version: 1.0
In-Reply-To: <20170911201506.GA15044@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Cc: tj@kernel.org, geliangtang@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

On 09/11/2017 02:15 PM, Jan Kara wrote:
> On Mon 11-09-17 21:43:23, Christophe JAILLET wrote:
>> If the 'kmalloc' fails, we must go through the existing error handling
>> path.
>>
>> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> 
> Looks good to me. You can add:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>

I'll queue it up, with your reviewed-by added. Thanks.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
