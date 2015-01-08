Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 590CD6B0032
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 05:55:05 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lf10so11104316pab.5
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 02:55:05 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id z9si7816765par.226.2015.01.08.02.55.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 08 Jan 2015 02:55:04 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NHU00C2KUIE1480@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 08 Jan 2015 10:59:03 +0000 (GMT)
Message-id: <54AE61F6.808@samsung.com>
Date: Thu, 08 Jan 2015 11:54:46 +0100
From: Andrzej Hajda <a.hajda@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC PATCH 0/4] kstrdup optimization
References: <54A25135.5030103@samsung.com>
 <20141230083230.GA17639@rhlx01.hs-esslingen.de>
 <20141230212915.GN2915@two.firstfloor.org>
In-reply-to: <20141230212915.GN2915@two.firstfloor.org>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>, Andreas Mohr <andi@lisas.de>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org

Hi Andi, Andreas,

Thanks for comments.

On 12/30/2014 10:29 PM, Andi Kleen wrote:
>> This symmetry issue probably could be cleanly avoided only
>> by having kfree() itself contain such an identifying check, as you suggest
>> (thereby slowing down kfree() performance).
> 
> It actually shouldn't slow it down. kfree already complains if you free
> a non slab page, this could be just in front of the error check.
> 
> The bigger concern is that it may hide some programing errors elsewhere
> though. So it's probably better to keep it a separate function.

Shall I interpret it as preliminary ack?

If yes, I can repost it without RFC prefix. Anyway I need to:
- add EXPORT_SYMBOL(kstrdup_const),
- add kerneldocs for both functions.

I can also add patch constifying mnt->mnt_devname in alloc_vfsmnt,
on my test platform it could save 13 additional allocations.

Regards
Andrzej


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
