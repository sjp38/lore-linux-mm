Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 08A796B0031
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 15:56:52 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id hn9so1672299wib.6
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 12:56:52 -0800 (PST)
Received: from mail-we0-x231.google.com (mail-we0-x231.google.com [2a00:1450:400c:c03::231])
        by mx.google.com with ESMTPS id g4si180419wiz.47.2013.12.13.12.56.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 12:56:51 -0800 (PST)
Received: by mail-we0-f177.google.com with SMTP id u56so2391763wes.22
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 12:56:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131122172147.GA6477@cerebellum.variantweb.net>
References: <1384965522-5788-1-git-send-email-ddstreet@ieee.org> <20131122172147.GA6477@cerebellum.variantweb.net>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 13 Dec 2013 15:56:31 -0500
Message-ID: <CALZtONBo-6_BKKT62BTzH3qyD4A+bxj781yGPa00fuFQ4TYdBQ@mail.gmail.com>
Subject: Re: [PATCH] mm/zswap: change params from hidden to ro
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

On Fri, Nov 22, 2013 at 12:21 PM, Seth Jennings
<sjennings@variantweb.net> wrote:
> On Wed, Nov 20, 2013 at 11:38:42AM -0500, Dan Streetman wrote:
>> The "compressor" and "enabled" params are currently hidden,
>> this changes them to read-only, so userspace can tell if
>> zswap is enabled or not and see what compressor is in use.
>
> Reasonable to me.
>
> Acked-by: Seth Jennings <sjennings@variantweb.net>

Ping to see if this patch could get picked up.

>
>>
>> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
>> ---
>>  mm/zswap.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/zswap.c b/mm/zswap.c
>> index d93510c..36b268b 100644
>> --- a/mm/zswap.c
>> +++ b/mm/zswap.c
>> @@ -77,12 +77,12 @@ static u64 zswap_duplicate_entry;
>>  **********************************/
>>  /* Enable/disable zswap (disabled by default, fixed at boot for now) */
>>  static bool zswap_enabled __read_mostly;
>> -module_param_named(enabled, zswap_enabled, bool, 0);
>> +module_param_named(enabled, zswap_enabled, bool, 0444);
>>
>>  /* Compressor to be used by zswap (fixed at boot for now) */
>>  #define ZSWAP_COMPRESSOR_DEFAULT "lzo"
>>  static char *zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
>> -module_param_named(compressor, zswap_compressor, charp, 0);
>> +module_param_named(compressor, zswap_compressor, charp, 0444);
>>
>>  /* The maximum percentage of memory that the compressed pool can occupy */
>>  static unsigned int zswap_max_pool_percent = 20;
>> --
>> 1.8.3.1
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
