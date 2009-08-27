Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 02C436B004F
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 12:04:08 -0400 (EDT)
Message-ID: <4A96AE4E.5000105@nokia.com>
Date: Thu, 27 Aug 2009 19:03:26 +0300
From: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
Reply-To: Artem.Bityutskiy@nokia.com
MIME-Version: 1.0
Subject: Re: [PATCH] SLUB: fix ARCH_KMALLOC_MINALIGN cases 64 and 256
References: <> <1251387491-8417-1-git-send-email-aaro.koskinen@nokia.com> <alpine.DEB.1.10.0908271151100.17470@gentwo.org>
In-Reply-To: <alpine.DEB.1.10.0908271151100.17470@gentwo.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "Koskinen Aaro (Nokia-D/Helsinki)" <aaro.koskinen@nokia.com>, "mpm@selenic.com" <mpm@selenic.com>, "penberg@cs.helsinki.fi" <penberg@cs.helsinki.fi>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 08/27/2009 06:56 PM, ext Christoph Lameter wrote:
> On Thu, 27 Aug 2009, Aaro Koskinen wrote:
>
>> +++ b/include/linux/slub_def.h
>> @@ -154,8 +154,10 @@ static __always_inline int kmalloc_index(size_t size)
>>   		return KMALLOC_SHIFT_LOW;
>>
>>   #if KMALLOC_MIN_SIZE<= 64
>> +#if KMALLOC_MIN_SIZE<= 32
>>   	if (size>  64&&  size<= 96)
>>   		return 1;
>> +#endif
>
> Use elif here to move the condition together with the action?

Just a related question. KMALLOC_MIN_SIZE sounds confusing. If this is
about alignment, why not to call it KMALLOC_MIN_ALIGN instead?

-- 
Best Regards,
Artem Bityutskiy (D?N?N?N?D 1/4  D?D,N?N?N?DoD,D1)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
