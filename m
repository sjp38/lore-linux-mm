Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 66C026B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 21:50:53 -0400 (EDT)
Message-ID: <4F98AA1D.1040009@kernel.org>
Date: Thu, 26 Apr 2012 10:51:25 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 4/6] zsmalloc: add/fix function comment
References: <1335334994-22138-1-git-send-email-minchan@kernel.org> <1335334994-22138-5-git-send-email-minchan@kernel.org> <4F97FBB1.1090001@vflare.org>
In-Reply-To: <4F97FBB1.1090001@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/25/2012 10:27 PM, Nitin Gupta wrote:

> On 04/25/2012 02:23 AM, Minchan Kim wrote:
> 
>> Add/fix the comment.
>>
>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>> ---
>>  drivers/staging/zsmalloc/zsmalloc-main.c |   15 +++++++++++----
>>  1 file changed, 11 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
>> index 0fe4cbb..b7d31cc 100644
>> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
>> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
>> @@ -565,12 +565,9 @@ EXPORT_SYMBOL_GPL(zs_destroy_pool);
>>   * zs_malloc - Allocate block of given size from pool.
>>   * @pool: pool to allocate from
>>   * @size: size of block to allocate
>> - * @page: page no. that holds the object
>> - * @offset: location of object within page
>>   *
>>   * On success, <page, offset> identifies block allocated
>> - * and 0 is returned. On failure, <page, offset> is set to
>> - * 0 and -ENOMEM is returned.
>> + * and <page, offset> is returned. On failure, NULL is returned.
>>   *
> 
> 
> The returned value indeed encodes <page, offset> values as a 'void *'
> but this should not be part of the function documentation since its an
> internal detail.  So, its probably better to say:
> 
> On success, handle to the allocated object is returned; NULL otherwise.


Fair enough.

> 
> On a side note, we should also 'typedef void * zs_handle' to avoid any
> confusion. Without this, users may just treat zs_malloc return value as
> a pointer and try to deference it.


Yes. We should do it. I will make it as another patch in next spin.

> 
>>   * Allocation requests with size > ZS_MAX_ALLOC_SIZE will fail.
>>   */
>> @@ -666,6 +663,16 @@ void zs_free(struct zs_pool *pool, void *obj)
>>  }
>>  EXPORT_SYMBOL_GPL(zs_free);
>>  
>> +/**
>> + * zs_map_object - get address of allocated object from handle.
>> + * @pool: object allocated pool
> 
> 
> should be: @pool: pool from which the object was allocated
> 
>> + * @handle: handle returned from zs_malloc
>> + *
> 
>> + * Before using object allocated from zs_malloc, object
>> + * should be mapped to page table by this function.
>> + * After using object,  call zs_unmap_object to unmap page
>> + * table.
>> + */
> 
> 
> We are not really unmapping any page tables, so could be written as:
> 
> Before using an object allocated from zs_malloc, it must be mapped using
> this function. When done with the object, it must be unmapped using
> zs_unmap_object
> 
> 
> Sorry for nitpicking.


Never nitpicking.
Confusing documentation makes people very hang so documentation is very important.

Nitin, Thanks!

> 
> Thanks,
> Nitin
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
