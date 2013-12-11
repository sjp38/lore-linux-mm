Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id EDD736B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 19:35:01 -0500 (EST)
Received: by mail-yh0-f43.google.com with SMTP id a41so4521815yho.16
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 16:35:01 -0800 (PST)
Received: from mail-ie0-x22f.google.com (mail-ie0-x22f.google.com [2607:f8b0:4001:c03::22f])
        by mx.google.com with ESMTPS id j69si15555064yhb.171.2013.12.10.16.35.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 16:35:01 -0800 (PST)
Received: by mail-ie0-f175.google.com with SMTP id x13so9913285ief.20
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 16:35:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52A79B0D.4090303@zytor.com>
References: <52A6D9B0.7040506@huawei.com>
	<CAE9FiQUd+sU4GEq0687u8+26jXJiJVboN90+L7svyosmm+V1Rg@mail.gmail.com>
	<52A787D0.2070400@zytor.com>
	<CAE9FiQU8Y_thGxZamz0Uwt4FGXh7KJu7jGP8ED3dbjQuyq7vcQ@mail.gmail.com>
	<52A79B0D.4090303@zytor.com>
Date: Tue, 10 Dec 2013 16:35:00 -0800
Message-ID: <CAE9FiQVf+vAbW1v_VL5XSseQg06S6AX8RrE4vvJwPbLOeRcr=A@mail.gmail.com>
Subject: Re: [PATCH] mm,x86: fix span coverage in e820_all_mapped()
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

On Tue, Dec 10, 2013 at 2:51 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 12/10/2013 01:52 PM, Yinghai Lu wrote:
>>>
>>> What happens if it spans more than two regions?
>>
>> [A, B), [B+1, C), [C+1, D) ?
>> start in [A, B), and end in [C+1, D).
>>
>> old code:
>> first with [A, B), start set to B.
>> then with [B+1, C), start still keep as B.
>> then with [C+1, D), start still keep as B.
>> at last still return 0...aka not_all_mapped.
>>
>> old code is still right.
>>
>
> Why not_all_mapped?

[B, B+1), and [C, C+1) are not there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
