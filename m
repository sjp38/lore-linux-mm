Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id C7B176B0035
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 00:28:01 -0500 (EST)
Received: by mail-yh0-f45.google.com with SMTP id v1so4620572yhn.4
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 21:28:01 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id v3si16423852yhd.238.2013.12.10.21.28.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Dec 2013 21:28:00 -0800 (PST)
In-Reply-To: <52A7EC9B.2080209@huawei.com>
References: <52A6D9B0.7040506@huawei.com> <CAE9FiQUd+sU4GEq0687u8+26jXJiJVboN90+L7svyosmm+V1Rg@mail.gmail.com> <52A7C16A.9040106@huawei.com> <52A7D415.6010908@zytor.com> <52A7E223.9030605@huawei.com> <52A7E3E5.2010609@zytor.com> <52A7EC9B.2080209@huawei.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain;
 charset=UTF-8
Subject: Re: [PATCH] mm,x86: fix span coverage in e820_all_mapped()
From: "H. Peter Anvin" <hpa@zytor.com>
Date: Tue, 10 Dec 2013 21:27:16 -0800
Message-ID: <64518090-daf1-4382-8a9e-c56e55bfbd7b@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Yinghai Lu <yinghai@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

Is that an actual requirement of the API?

Xishi Qiu <qiuxishi@huawei.com> wrote:
>On 2013/12/11 12:02, H. Peter Anvin wrote:
>
>> On 12/10/2013 07:55 PM, Xishi Qiu wrote:
>>>
>>> I think there is a problem.
>>> e.g.
>>> [start, end)=[8, 12), and [A, B)=[0, 10), [B, C)=[10,20),
>>> then e820_all_mapped() will return 1, it spans two regions.
>>>
>> 
>> Why is that a problem?
>> 
>
>[start, end) should be included in one region ?
>
>Thanks,
>Xishi Qiu
>
>> 	-hpa
>> 
>> 
>> 
>> 

-- 
Sent from my Android phone with K-9 Mail. Please excuse my brevity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
