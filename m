Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: RE: [PATCH 1/4] [mm] buddy page allocator: add tunable big order allocation
Date: Tue, 13 May 2008 12:42:13 +0100
Message-ID: <8A42379416420646B9BFAC9682273B6D015F52E4@limkexm3.ad.analog.com>
In-Reply-To: <20080513110902.80a87ac9.kamezawa.hiroyu@jp.fujitsu.com>
References: <1210588325-11027-1-git-send-email-cooloney@kernel.org><1210588325-11027-2-git-send-email-cooloney@kernel.org> <20080513110902.80a87ac9.kamezawa.hiroyu@jp.fujitsu.com>
From: "Hennerich, Michael" <Michael.Hennerich@analog.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bryan Wu <cooloney@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dwmw2@infradead.org, Michael Hennerich <michael.hennerich@analog.com>
List-ID: <linux-mm.kvack.org>


>-----Original Message-----
>From: KAMEZAWA Hiroyuki [mailto:kamezawa.hiroyu@jp.fujitsu.com]
>Sent: Dienstag, 13. Mai 2008 04:09
>To: Bryan Wu
>Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org;
dwmw2@infradead.org;
>Michael Hennerich
>Subject: Re: [PATCH 1/4] [mm] buddy page allocator: add tunable big
order
>allocation
>
>On Mon, 12 May 2008 18:32:02 +0800
>Bryan Wu <cooloney@kernel.org> wrote:
>
>> From: Michael Hennerich <michael.hennerich@analog.com>
>>
>> Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
>> Signed-off-by: Bryan Wu <cooloney@kernel.org>
>
>Does this really solve your problem ? possible hang-up is better than
>page allocation failure ?

On nommu this helped quite a bit, when we run out of memory, eaten up by
the page cache. But yes - with this option it's likely that we sit there
and wait form memory that might never get available.

We now use a better workaround for freeing up "available" memory
currently used as page cache.

I think we should drop this patch.

Best regards,
Michael 

>
>> ---
>>  init/Kconfig    |    9 +++++++++
>>  mm/page_alloc.c |    2 +-
>>  2 files changed, 10 insertions(+), 1 deletions(-)
>>
>> diff --git a/init/Kconfig b/init/Kconfig
>> index 6135d07..b6ff75b 100644
>> --- a/init/Kconfig
>> +++ b/init/Kconfig
>> @@ -742,6 +742,15 @@ config SLUB_DEBUG
>>  	  SLUB sysfs support. /sys/slab will not exist and there will be
>>  	  no support for cache validation etc.
>>
>> +config BIG_ORDER_ALLOC_NOFAIL_MAGIC
>> +	int "Big Order Allocation No FAIL Magic"
>> +	depends on EMBEDDED
>> +	range 3 10
>> +	default 3
>> +	help
>> +	  Let big-order allocations loop until memory gets free.
Specified
>Value
>> +	  expresses the order.
>> +
>I think it's better to add a text to explain why this is for EMBEDED.
>
>Thanks,
>-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
