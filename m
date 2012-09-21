Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id C61A16B0044
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 14:31:50 -0400 (EDT)
Message-ID: <505CB289.2040307@kernel.dk>
Date: Fri, 21 Sep 2012 20:31:37 +0200
From: Jens Axboe <axboe@kernel.dk>
MIME-Version: 1.0
Subject: Re: Query of zram/zsmalloc promotion
References: <20120912023914.GA31715@bbox> <20120921164112.GD4780@phenom.dumpdata.com>
In-Reply-To: <20120921164112.GD4780@phenom.dumpdata.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 2012-09-21 18:41, Konrad Rzeszutek Wilk wrote:
> On Wed, Sep 12, 2012 at 11:39:14AM +0900, Minchan Kim wrote:
>> Hi all,
>>
>> I would like to promote zram/zsmalloc from staging tree.
>> I already tried it https://lkml.org/lkml/2012/8/8/37 but I didn't get
>> any response from you guys.
>>
>> I think zram/zsmalloc's code qulity is good and they
>> are used for many embedded vendors for a long time.
>> So it's proper time to promote them.
>>
>> The zram should put on under driver/block/. I think it's not
>> arguable but the issue is which directory we should keep *zsmalloc*.
>>
>> Now Nitin want to keep it with zram so it would be in driver/blocks/zram/
>> But I don't like it because zsmalloc touches several fields of struct page
>> freely(and AFAIRC, Andrew had a same concern with me) so I want to put
>> it under mm/.
> 
> I like the idea of keeping it in /lib or /mm. Actually 'lib' sounds more
> appropriate since it is dealing with storing a bunch of pages in a nice
> layout for great density purposes.
>>
>> In addtion, now zcache use it, too so it's rather awkward if we put it
>> under dirver/blocks/zram/.
>>
>> So questions.
>>
>> To Andrew:
>> Is it okay to put it under mm/ ? Or /lib?
>>
>> To Jens:
>> Is it okay to put zram under drvier/block/ If you are okay, I will start sending
>> patchset after I sort out zsmalloc's location issue.
> 
> I would think it would be OK.

We can certainly put it in drivers/block, I have no issue with that.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
