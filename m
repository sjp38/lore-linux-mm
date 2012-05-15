Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 6E3C66B00E7
	for <linux-mm@kvack.org>; Mon, 14 May 2012 22:21:00 -0400 (EDT)
Message-ID: <4FB1BDAB.7090609@kernel.org>
Date: Tue, 15 May 2012 11:21:31 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] zsmalloc use zs_handle instead of void *
References: <4FAB21E7.7020703@kernel.org> <20120510140215.GC26152@phenom.dumpdata.com> <4FABD503.4030808@vflare.org> <4FABDA9F.1000105@linux.vnet.ibm.com> <20120510151941.GA18302@kroah.com> <4FABECF5.8040602@vflare.org> <20120510164418.GC13964@kroah.com> <4FABF9D4.8080303@vflare.org> <20120510173322.GA30481@phenom.dumpdata.com> <4FAC4E3B.3030909@kernel.org> <20120511192831.GC3785@phenom.dumpdata.com> <4FB06B91.1080008@kernel.org> <CAPkvG_dTA7HwzVBo70bZuqkX+ZfjJpS+p4L9L+jF4Uz1ooEx0Q@mail.gmail.com>
In-Reply-To: <CAPkvG_dTA7HwzVBo70bZuqkX+ZfjJpS+p4L9L+jF4Uz1ooEx0Q@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/15/2012 10:57 AM, Nitin Gupta wrote:

<SNIP>

>>>
>>>>
>>>>
>>>>>> Its true that making it a real struct would prevent accidental casts
>>>>>> to void * but due to the above problem, I think we have to stick
>>>>>> with unsigned long.
>>>
>>> So the problem you are seeing is that you don't want 'struct zs_handle'
>>> be present in the drivers/staging/zsmalloc/zsmalloc.h header file?
>>> It looks like the proper place.
>>
>>
>> No. What I want is to remove coupling zsallocator's handle with zram/zcache.
>> They shouldn't know internal of handle and assume it's a pointer.
>>
>> If Nitin confirm zs_handle's format can never change in future, I prefer "unsigned long" Nitin suggested than (void *).
>> It can prevent confusion that normal allocator's return value is pointer for address so the problem is easy.
>> But I am not sure he can make sure it.
>>
> 
> zs_handle will always be an unsigned long so its better to just use
> the same as return type.


Okay. it makes problem very easy.

> 
> Another alternative is to return 'struct zs_handle *' which can be
> used as a 'void *' by zcache and as unsigned long by zsmalloc.
> However, I see no good reason for preferring this over simple unsigned
> long as the return type.


Agreed.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
