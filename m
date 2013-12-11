Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 11B546B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 23:43:15 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id jt11so9201764pbb.28
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 20:43:15 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id ty3si12351290pbc.197.2013.12.10.20.43.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 20:43:14 -0800 (PST)
Message-ID: <52A7EC9B.2080209@huawei.com>
Date: Wed, 11 Dec 2013 12:39:55 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm,x86: fix span coverage in e820_all_mapped()
References: <52A6D9B0.7040506@huawei.com> <CAE9FiQUd+sU4GEq0687u8+26jXJiJVboN90+L7svyosmm+V1Rg@mail.gmail.com> <52A7C16A.9040106@huawei.com> <52A7D415.6010908@zytor.com> <52A7E223.9030605@huawei.com> <52A7E3E5.2010609@zytor.com>
In-Reply-To: <52A7E3E5.2010609@zytor.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Yinghai Lu <yinghai@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

On 2013/12/11 12:02, H. Peter Anvin wrote:

> On 12/10/2013 07:55 PM, Xishi Qiu wrote:
>>
>> I think there is a problem.
>> e.g.
>> [start, end)=[8, 12), and [A, B)=[0, 10), [B, C)=[10,20),
>> then e820_all_mapped() will return 1, it spans two regions.
>>
> 
> Why is that a problem?
> 

[start, end) should be included in one region ?

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
