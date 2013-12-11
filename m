Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id 35C8F6B0070
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 20:07:11 -0500 (EST)
Received: by mail-yh0-f51.google.com with SMTP id c41so4526209yho.38
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 17:07:11 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id v1si15666227yhg.76.2013.12.10.17.07.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Dec 2013 17:07:10 -0800 (PST)
In-Reply-To: <CAE9FiQVf+vAbW1v_VL5XSseQg06S6AX8RrE4vvJwPbLOeRcr=A@mail.gmail.com>
References: <52A6D9B0.7040506@huawei.com> <CAE9FiQUd+sU4GEq0687u8+26jXJiJVboN90+L7svyosmm+V1Rg@mail.gmail.com> <52A787D0.2070400@zytor.com> <CAE9FiQU8Y_thGxZamz0Uwt4FGXh7KJu7jGP8ED3dbjQuyq7vcQ@mail.gmail.com> <52A79B0D.4090303@zytor.com> <CAE9FiQVf+vAbW1v_VL5XSseQg06S6AX8RrE4vvJwPbLOeRcr=A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH] mm,x86: fix span coverage in e820_all_mapped()
From: "H. Peter Anvin" <hpa@zytor.com>
Date: Tue, 10 Dec 2013 17:06:36 -0800
Message-ID: <b2e6fc81-a956-46f7-9a44-a707064c24a2@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

Ok, the issue I thought we were discussing was actually [A,B) [B,C) [C,D) ...

Yinghai Lu <yinghai@kernel.org> wrote:
>On Tue, Dec 10, 2013 at 2:51 PM, H. Peter Anvin <hpa@zytor.com> wrote:
>> On 12/10/2013 01:52 PM, Yinghai Lu wrote:
>>>>
>>>> What happens if it spans more than two regions?
>>>
>>> [A, B), [B+1, C), [C+1, D) ?
>>> start in [A, B), and end in [C+1, D).
>>>
>>> old code:
>>> first with [A, B), start set to B.
>>> then with [B+1, C), start still keep as B.
>>> then with [C+1, D), start still keep as B.
>>> at last still return 0...aka not_all_mapped.
>>>
>>> old code is still right.
>>>
>>
>> Why not_all_mapped?
>
>[B, B+1), and [C, C+1) are not there.

-- 
Sent from my mobile phone.  Please pardon brevity and lack of formatting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
