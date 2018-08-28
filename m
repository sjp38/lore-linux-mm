Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6D46F6B4894
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 19:09:35 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 199-v6so1883790wme.1
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 16:09:35 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id w3-v6si1995855wmb.7.2018.08.28.16.09.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 Aug 2018 16:09:31 -0700 (PDT)
Subject: Re: Tagged pointers in the XArray
References: <20180828222727.GD11400@bombadil.infradead.org>
 <fc15502d-8bf3-b7e3-af82-4645dc84e9cd@infradead.org>
 <20180828230329.GE11400@bombadil.infradead.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <8352b2da-b638-2205-132b-f32893d1cdb7@infradead.org>
Date: Tue, 28 Aug 2018 16:09:23 -0700
MIME-Version: 1.0
In-Reply-To: <20180828230329.GE11400@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, zhong jiang <zhongjiang@huawei.com>, Chao Yu <yuchao0@huawei.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 08/28/2018 04:03 PM, Matthew Wilcox wrote:
> On Tue, Aug 28, 2018 at 03:39:01PM -0700, Randy Dunlap wrote:
>> Just a question, please...
>>
>> On 08/28/2018 03:27 PM, Matthew Wilcox wrote:
>>>
>>> diff --git a/include/linux/xarray.h b/include/linux/xarray.h
>>> index c74556ea4258..d1b383f3063f 100644
>>> --- a/include/linux/xarray.h
>>> +++ b/include/linux/xarray.h
>>> @@ -150,6 +150,54 @@ static inline int xa_err(void *entry)
>>>  	return 0;
>>>  }
>>>  
>>> +/**
>>> + * xa_tag_pointer() - Create an XArray entry for a tagged pointer.
>>> + * @p: Plain pointer.
>>> + * @tag: Tag value (0, 1 or 3).
>>> + *
>>
>> What's wrong with a tag value of 2?
> 
> That conflicts with the XArray's internal entries and you get a WARN_ON
> when you try to store it in the array.
> 
>> and what happens when one is used?  [I don't see anything preventing that.]
> 
> Right, there's nothing preventing you from using the value 5 or 19
> or 16777216 either ... I did put in a WARN_ON_ONCE to begin with, but
> decided that was unnecessary.
> 
> Right now our only user uses 0 and 1, so even documenting 3 as a
> possibility isn't _necessary_, but some day somebody is going to want
> to add FILE_NOT_FOUND
> https://thedailywtf.com/articles/What_Is_Truth_0x3f_
> 

Thanks.  :)

-- 
~Randy
