Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 5DC4E8D0001
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 08:14:37 -0400 (EDT)
Received: from eusync2.samsung.com (mailout3.w1.samsung.com [210.118.77.13])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M57008F93DCSI90@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 06 Jun 2012 13:15:12 +0100 (BST)
Received: from [106.116.48.223] by eusync2.samsung.com
 (Oracle Communications Messaging Server 7u4-23.01(7.0.4.23.0) 64bit (built Aug
 10 2011)) with ESMTPA id <0M5700BNZ3C9AA70@eusync2.samsung.com> for
 linux-mm@kvack.org; Wed, 06 Jun 2012 13:14:34 +0100 (BST)
Message-id: <4FCF49A7.8040203@samsung.com>
Date: Wed, 06 Jun 2012 14:14:31 +0200
From: Tomasz Stanislawski <t.stanislaws@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v3] scatterlist: add sg_alloc_table_from_pages function
References: <4FA8EC69.8010805@samsung.com>
 <20120517165614.d5e6e4b6.akpm@linux-foundation.org>
 <4FBA4ACE.4080602@samsung.com>
 <20120522131059.415a881c.akpm@linux-foundation.org>
In-reply-to: <20120522131059.415a881c.akpm@linux-foundation.org>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: paul.gortmaker@windriver.com, =?UTF-8?B?J+uwleqyveuvvCc=?= <kyungmin.park@samsung.com>, amwang@redhat.com, dri-devel@lists.freedesktop.org, "'???/Mobile S/W Platform Lab.(???)/E3(??)/????'" <inki.dae@samsung.com>, prashanth.g@samsung.com, Marek Szyprowski <m.szyprowski@samsung.com>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Rob Clark <rob@ti.com>, Dave Airlie <airlied@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Johannes Weiner <hannes@cmpxchg.org>

On 05/22/2012 10:10 PM, Andrew Morton wrote:
> On Mon, 21 May 2012 16:01:50 +0200
> Tomasz Stanislawski <t.stanislaws@samsung.com> wrote:
> 
>>>> +int sg_alloc_table_from_pages(struct sg_table *sgt,
>>>> +	struct page **pages, unsigned int n_pages,
>>>> +	unsigned long offset, unsigned long size,
>>>> +	gfp_t gfp_mask)
>>>
>>> I guess a 32-bit n_pages is OK.  A 16TB IO seems enough ;)
>>>
>>
>> Do you think that 'unsigned long' for offset is too big?
>>
>> Ad n_pages. Assuming that Moore's law holds it will take
>> circa 25 years before the limit of 16 TB is reached :) for
>> high-end scatterlist operations.
>> Or I can change the type of n_pages to 'unsigned long' now at
>> no cost :).
> 
> By then it will be Someone Else's Problem ;)
> 

Ok. So let's keep to 'unsigned int n_pages'.

>>>> +{
>>>> +	unsigned int chunks;
>>>> +	unsigned int i;
>>>
>>> erk, please choose a different name for this.  When a C programmer sees
>>> "i", he very much assumes it has type "int".  Making it unsigned causes
>>> surprise.
>>>
>>> And don't rename it to "u"!  Let's give it a nice meaningful name.  pageno?
>>>
>>
>> The problem is that 'i' is  a natural name for a loop counter.
> 
> It's also the natural name for an integer.  If a C programmer sees "i",
> he thinks "int".  It's a Fortran thing ;)
> 
>> AFAIK, in the kernel code developers try to avoid Hungarian notation.
>> A name of a variable should reflect its purpose, not its type.
>> I can change the name of 'i' to 'pageno' and 'j' to 'pageno2' (?)
>> but I think it will make the code less reliable.
> 
> Well, one could do something radical such as using "p".
> 
> 

I can not change the type to 'int' due to 'signed vs unsigned' comparisons
in the loop condition.
What do you think about changing the names 'i' -> 'p' and 'j' -> 'q'?

Regards,
Tomasz Stanislawski

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
