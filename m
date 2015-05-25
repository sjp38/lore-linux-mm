Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 149666B00FC
	for <linux-mm@kvack.org>; Mon, 25 May 2015 04:05:21 -0400 (EDT)
Received: by pdea3 with SMTP id a3so65076329pde.2
        for <linux-mm@kvack.org>; Mon, 25 May 2015 01:05:20 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id fn7si15097164pdb.248.2015.05.25.01.05.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 25 May 2015 01:05:20 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NOW00ASMBSR0Y90@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 25 May 2015 09:05:15 +0100 (BST)
Message-id: <5562D7B9.70106@samsung.com>
Date: Mon, 25 May 2015 10:05:13 +0200
From: Marcin Jabrzyk <m.jabrzyk@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] zram: check compressor name before setting it
References: <1432283515-2005-1-git-send-email-m.jabrzyk@samsung.com>
 <20150522085523.GA709@swordfish> <555EF30C.60108@samsung.com>
 <20150522124411.GA3793@swordfish> <555F2E7C.4090707@samsung.com>
 <20150525061838.GB555@swordfish> <5562CBF4.2090007@samsung.com>
 <20150525073400.GD555@swordfish>
In-reply-to: <20150525073400.GD555@swordfish>
Content-type: text/plain; charset=windows-1252; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: minchan@kernel.org, ngupta@vflare.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com



On 25/05/15 09:34, Sergey Senozhatsky wrote:
> On (05/25/15 09:15), Marcin Jabrzyk wrote:
> [..]
>>>
>> I'm perfectly fine with this solution. It just does what
>> I'd expect.
>
> cool, let's hear from Minchan.
>
> btw, if we decide to move on, how do you guys want to route
> it? do you want Marcin (I don't mind)  or me  (of course,
> with the appropriate credit to Marcin) to submit it?
>
It this get accepted, then I'm fine with you to submit it.

Best regards,
Marcin Jabrzyk

> 	-ss
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
