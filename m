Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id F02D36B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 22:58:46 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id g10so8735111pdj.29
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 19:58:46 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id bc2si12217836pad.129.2013.12.10.19.58.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 19:58:45 -0800 (PST)
Message-ID: <52A7E223.9030605@huawei.com>
Date: Wed, 11 Dec 2013 11:55:15 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm,x86: fix span coverage in e820_all_mapped()
References: <52A6D9B0.7040506@huawei.com> <CAE9FiQUd+sU4GEq0687u8+26jXJiJVboN90+L7svyosmm+V1Rg@mail.gmail.com> <52A7C16A.9040106@huawei.com> <52A7D415.6010908@zytor.com>
In-Reply-To: <52A7D415.6010908@zytor.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Yinghai Lu <yinghai@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

On 2013/12/11 10:55, H. Peter Anvin wrote:

> On 12/10/2013 05:35 PM, Xishi Qiu wrote:
>>
>> In this case, old code is right, but I discuss in another one that
>> you wrote above.
>>
> 
> So is there a problem or not?  I have lost track...
> 

I think there is a problem.
e.g.
[start, end)=[8, 12), and [A, B)=[0, 10), [B, C)=[10,20),
then e820_all_mapped() will return 1, it spans two regions.

Thanks,
Xishi Qiu

> 	-hpa
> 
> 
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
