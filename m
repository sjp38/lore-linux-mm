Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id F043F6B02EA
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 16:07:30 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 11so18150522pge.4
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 13:07:30 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f9sor3894732pgp.86.2017.09.11.13.07.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Sep 2017 13:07:29 -0700 (PDT)
Subject: Re: [PATCH] mm/backing-dev.c: fix an error handling path in
 'cgwb_create()'
References: <20170911194323.17833-1-christophe.jaillet@wanadoo.fr>
 <512a90ae-a8bf-7ead-32ba-b4fe36866b20@kernel.dk>
 <1c50dbc9-f765-5b90-1f00-7d87205382d7@wanadoo.fr>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <e24134e3-e063-bbb9-5570-26f00e36a503@kernel.dk>
Date: Mon, 11 Sep 2017 14:07:27 -0600
MIME-Version: 1.0
In-Reply-To: <1c50dbc9-f765-5b90-1f00-7d87205382d7@wanadoo.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>, jack@suse.cz, tj@kernel.org, geliangtang@gmail.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

On 09/11/2017 02:04 PM, Christophe JAILLET wrote:
> Le 11/09/2017 A  21:52, Jens Axboe a A(C)crit :
>> On 09/11/2017 01:43 PM, Christophe JAILLET wrote:
>>> If the 'kmalloc' fails, we must go through the existing error handling
>>> path.
>> Looks good to me, probably wants a
>>
>> Fixes: 52ebea749aae ("writeback: make backing_dev_info host cgroup-specific bdi_writebacks")
>>
>> line as well.
>>
> Hi,
> 
> do you want me to resend with the Fixes tag? Or will it be added if merged?

Shouldn't be necessary to resend. Not sure who will queue it up, mm/ always
ends up being somewhat of a no-mans-land :-)

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
