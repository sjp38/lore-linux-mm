Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id CAD726B0266
	for <linux-mm@kvack.org>; Fri, 22 May 2015 05:12:51 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so14928676pdb.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 02:12:51 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id q9si2510504par.165.2015.05.22.02.12.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 22 May 2015 02:12:51 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NOQ00KTBUXA9T90@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 22 May 2015 10:12:46 +0100 (BST)
Message-id: <555EF30C.60108@samsung.com>
Date: Fri, 22 May 2015 11:12:44 +0200
From: Marcin Jabrzyk <m.jabrzyk@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] zram: check compressor name before setting it
References: <1432283515-2005-1-git-send-email-m.jabrzyk@samsung.com>
 <20150522085523.GA709@swordfish>
In-reply-to: <20150522085523.GA709@swordfish>
Content-type: text/plain; charset=windows-1252; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: minchan@kernel.org, ngupta@vflare.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com

Hi,

On 22/05/15 10:56, Sergey Senozhatsky wrote:
> On (05/22/15 10:31), Marcin Jabrzyk wrote:
>> Zram sysfs interface was not making any check of
>> proper compressor name when setting it.
>> Any name is accepted, but further tries of device
>> creation would end up with not very meaningfull error.
>> eg.
>>
>> echo lz0 > comp_algorithm
>> echo 200M > disksize
>> echo: write error: Invalid argument
>>
>
> no.
>
> zram already complains about failed comp backend creation.
> it's in dmesg (or syslog, etc.):
>
> 	"zram: Cannot initialise %s compressing backend"
>
OK, now I see that. Sorry for the noise.

> second, there is not much value in exposing zcomp internals,
> especially when the result is just another line in dmesg output.

 From the other hand, the only valid values that can be written are
in 'comp_algorithm'.
So when writing other one, returning -EINVAL seems to be reasonable.
The user would get immediately information that he can't do that,
now the information can be very deferred in time.
I'm not for exposing more internals, but getting -EINVAL would be nice I 
think.

>
> 	-ss
>

Best regards,
Marcin Jabrzyk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
