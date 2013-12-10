Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id E061F6B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 17:52:24 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id f73so4485873yha.35
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 14:52:24 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id r49si15287217yho.217.2013.12.10.14.52.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Dec 2013 14:52:23 -0800 (PST)
Message-ID: <52A79B0D.4090303@zytor.com>
Date: Tue, 10 Dec 2013 14:51:57 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm,x86: fix span coverage in e820_all_mapped()
References: <52A6D9B0.7040506@huawei.com>	<CAE9FiQUd+sU4GEq0687u8+26jXJiJVboN90+L7svyosmm+V1Rg@mail.gmail.com>	<52A787D0.2070400@zytor.com> <CAE9FiQU8Y_thGxZamz0Uwt4FGXh7KJu7jGP8ED3dbjQuyq7vcQ@mail.gmail.com>
In-Reply-To: <CAE9FiQU8Y_thGxZamz0Uwt4FGXh7KJu7jGP8ED3dbjQuyq7vcQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

On 12/10/2013 01:52 PM, Yinghai Lu wrote:
>>
>> What happens if it spans more than two regions?
> 
> [A, B), [B+1, C), [C+1, D) ?
> start in [A, B), and end in [C+1, D).
> 
> old code:
> first with [A, B), start set to B.
> then with [B+1, C), start still keep as B.
> then with [C+1, D), start still keep as B.
> at last still return 0...aka not_all_mapped.
> 
> old code is still right.
> 

Why not_all_mapped?

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
