Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id E931182997
	for <linux-mm@kvack.org>; Fri, 22 May 2015 09:34:43 -0400 (EDT)
Received: by paza2 with SMTP id a2so10672653paz.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 06:34:43 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id pm11si3508112pdb.55.2015.05.22.06.34.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 22 May 2015 06:34:43 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NOR00MKZ71QMH50@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 22 May 2015 14:34:38 +0100 (BST)
Message-id: <555F306C.7080704@samsung.com>
Date: Fri, 22 May 2015 15:34:36 +0200
From: Marcin Jabrzyk <m.jabrzyk@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] zram: check compressor name before setting it
References: <1432283515-2005-1-git-send-email-m.jabrzyk@samsung.com>
 <20150522085523.GA709@swordfish> <555EF30C.60108@samsung.com>
 <20150522124411.GA3793@swordfish> <20150522131447.GA14922@blaptop>
In-reply-to: <20150522131447.GA14922@blaptop>
Content-type: text/plain; charset=windows-1252; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: ngupta@vflare.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com


Hello Minchan,

On 22/05/15 15:14, Minchan Kim wrote:
> Hello Sergey,
>
> On Fri, May 22, 2015 at 09:44:11PM +0900, Sergey Senozhatsky wrote:
>> On (05/22/15 11:12), Marcin Jabrzyk wrote:
>>>>
>>>> no.
>>>>
>>>> zram already complains about failed comp backend creation.
>>>> it's in dmesg (or syslog, etc.):
>>>>
>>>> 	"zram: Cannot initialise %s compressing backend"
>>>>
>>> OK, now I see that. Sorry for the noise.
>>>
>>>> second, there is not much value in exposing zcomp internals,
>>>> especially when the result is just another line in dmesg output.
>>>
>>>  From the other hand, the only valid values that can be written are
>>> in 'comp_algorithm'.
>>> So when writing other one, returning -EINVAL seems to be reasonable.
>>> The user would get immediately information that he can't do that,
>>> now the information can be very deferred in time.
>>
>> it's not.
>> the error message appears in syslog right before we return -EINVAL
>> back to user.
>
> Although Marcin's description is rather misleading, I like the patch.
> Every admin doesn't watch dmesg output. Even people could change loglevel
> simply so KERN_INFO would be void in that case.
Sorry for being confusing, at the first time I've overlooked that error 
message in syslog.
I didn't thought about looking for handling exactly this error in 
completely different place.

>
> Instant error propagation is more strighforward for user point of view
> rather than delaying with depending on another event.

Yes this was my exact motivation.
Instant value can be detected in scripts etc. Easier to debug in
automated environment.

>
> Thanks.
>
>>
>> 	-ss
>>
>>> I'm not for exposing more internals, but getting -EINVAL would be nice I
>

If this would be ok, I can prepare v2 with better description and with
less exposing zcomp internals.

Best regards,
Marcin Jabrzyk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
