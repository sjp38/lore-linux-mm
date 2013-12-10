Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2DC1A6B0044
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 21:14:20 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id b20so3405402yha.40
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 18:14:20 -0800 (PST)
Received: from mail-pb0-x230.google.com (mail-pb0-x230.google.com [2607:f8b0:400e:c01::230])
        by mx.google.com with ESMTPS id v65si11949612yhp.158.2013.12.09.18.14.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 18:14:19 -0800 (PST)
Received: by mail-pb0-f48.google.com with SMTP id md12so6609358pbc.35
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 18:14:18 -0800 (PST)
Message-ID: <52A67973.20904@gmail.com>
Date: Tue, 10 Dec 2013 10:16:19 +0800
From: Chen Gang <gang.chen.5i5j@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/zswap.c: add BUG() for default case in zswap_writeback_entry()
References: <52A53024.9090701@gmail.com> <20131209153626.GA3752@cerebellum.variantweb.net>
In-Reply-To: <20131209153626.GA3752@cerebellum.variantweb.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, James Hogan <james.hogan@imgtec.com>

On 12/09/2013 11:36 PM, Seth Jennings wrote:
> On Mon, Dec 09, 2013 at 10:51:16AM +0800, Chen Gang wrote:
>> Recommend to add default case to avoid compiler's warning, although at
>> present, the original implementation is still correct.
>>
>> The related warning (with allmodconfig for metag):
>>
>>     CC      mm/zswap.o
>>   mm/zswap.c: In function 'zswap_writeback_entry':
>>   mm/zswap.c:537: warning: 'ret' may be used uninitialized in this function
>>
>>
>> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
>> ---
>>  mm/zswap.c |    2 ++
>>  1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/zswap.c b/mm/zswap.c
>> index 5a63f78..bfd1807 100644
>> --- a/mm/zswap.c
>> +++ b/mm/zswap.c
>> @@ -585,6 +585,8 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
>>  
>>  		/* page is up to date */
>>  		SetPageUptodate(page);
>> +	default:
>> +		BUG();
> 
> Typically, the way you want to address this is initialize ret to 0
> at declaration time if not every control path will set that value.
> 

At least, your suggestion sounds reasonable.

But I am also aware that normally need content 'default' for 'switch',
so I choose this fix way.

And sorry, current patch is incorrect (need 'break' before 'default'),
so if no additional suggestions or discussions or completions, I
will/should send patch v2 for it.


Thanks.
-- 
Chen Gang

Open, share, and attitude like air, water and life which God blessed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
