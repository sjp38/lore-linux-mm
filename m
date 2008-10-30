Date: Thu, 30 Oct 2008 13:51:52 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] slab: unsigned slabp->inuse cannot be less than 0
In-Reply-To: <4909FBAE.4080002@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0810301350490.30797@quilx.com>
References: <4908D30F.1020206@gmail.com> <4909FBAE.4080002@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: roel kluin <roel.kluin@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ok here it is. But I think you are well capable of reviewing trivial 
patches on your own.

Acked-by: Christoph Lameter <cl@linux-foundation.org>

On Thu, 30 Oct 2008, Pekka Enberg wrote:

> roel kluin wrote:
>> unsigned slabp->inuse cannot be less than 0
>
> Christoph, this is on my to-merge list but an ACK would be nice.
>
>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
>> ---
>> N.B. It could be possible that a different check is needed.
>> I may not be able to respond for a few weeks.
>> 
>> diff --git a/mm/slab.c b/mm/slab.c
>> index 0918751..f634a87 100644
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -2997,7 +2997,7 @@ retry:
>>  		 * there must be at least one object available for
>>  		 * allocation.
>>  		 */
>> -		BUG_ON(slabp->inuse < 0 || slabp->inuse >= cachep->num);
>> +		BUG_ON(slabp->inuse >= cachep->num);
>>   		while (slabp->inuse < cachep->num && batchcount--) {
>>  			STATS_INC_ALLOCED(cachep);
>> 
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
