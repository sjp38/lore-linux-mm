Message-ID: <415B90F5.4060309@us.ibm.com>
Date: Wed, 29 Sep 2004 21:52:05 -0700
From: badari <pbadari@us.ibm.com>
MIME-Version: 1.0
Subject: Re: slab fragmentation ?
References: <1096500963.12861.21.camel@dyn318077bld.beaverton.ibm.com> <20040929204143.134154bc.akpm@osdl.org>
In-Reply-To: <20040929204143.134154bc.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: manfred@colorfullife.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:

>Badari Pulavarty <pbadari@us.ibm.com> wrote:
>  
>
>># name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <batchcount> <limit> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
>>size-40             2633  11468     64   61    1 : tunables  120   60    8 : slabdata    188    188      0
>>size-40             2633  11468     64   61    1 : tunables  120   60    8 : slabdata    188    188      0
>>size-40             2633  11468     64   61    1 : tunables  120   60    8 : slabdata    188    188      0
>>size-40             2633  11468     64   61    1 : tunables  120   60    8 : slabdata    188    188      0
>>size-40             4457  27084     64   61    1 : tunables  120   60    8 : slabdata    444    444      0
>>size-40             7685  59292     64   61    1 : tunables  120   60    8 : slabdata    972    972      0
>>size-40            10761  89548     64   61    1 : tunables  120   60    8 : slabdata   1468   1468      0
>>size-40            13589 119316     64   61    1 : tunables  120   60    8 : slabdata   1956   1956      0
>>size-40            16717 149084     64   61    1 : tunables  120   60    8 : slabdata   2444   2444      0
>>    
>>
>
>That looks like plain brokenness rather than fragmentation.  We shouldn't
>be allocating new pages until active_objs reaches num_objs, should we?
>  
>
Since i am using a 8 proc machine and we use per-cpu lists, I was 
expecting to see up to
8 partial pages maximum. (use and  active may differ by 8  * 60 entries).

I don't think accounting is broken. I used "crash" to look at each and 
every slab in the
cache and it seem to add up to same number of objects in use.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
