Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id DA9156B006C
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 09:16:51 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so651255pab.33
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 06:16:51 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id re11si1980120pdb.228.2014.11.25.06.16.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 25 Nov 2014 06:16:50 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NFL00IJDMGKFC80@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 25 Nov 2014 14:19:32 +0000 (GMT)
Message-id: <54748F4A.8030003@samsung.com>
Date: Tue, 25 Nov 2014 17:16:42 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v7 01/12] Add kernel address sanitizer infrastructure.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1416852146-9781-1-git-send-email-a.ryabinin@samsung.com>
 <1416852146-9781-2-git-send-email-a.ryabinin@samsung.com>
 <CAA6XgkH4soz_oCiO+X2Tibc3H6NHiZJp5ySzk5SSntD9dV6Gfw@mail.gmail.com>
In-reply-to: 
 <CAA6XgkH4soz_oCiO+X2Tibc3H6NHiZJp5ySzk5SSntD9dV6Gfw@mail.gmail.com>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Chernenkov <dmitryc@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Randy Dunlap <rdunlap@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, Michal Marek <mmarek@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On 11/25/2014 03:40 PM, Dmitry Chernenkov wrote:
> I'm a little concerned with how enabling/disabling works. If an
> enable() is forgotten once, it's disabled forever. If disable() is
> forgotten once, the toggle is reversed for the forseable future. MB
> check for inequality in kasan_enabled()? like current->kasan_depth >=
> 0 (will need a signed int for the field). Do you think it's going to
> decrease performance?

I think that check in kasan_enabled shouldn't hurt much.
But it also doesn't look very useful for me.

There are only few user of kasan_disable_local/kasan_enable_local, it's easy to review them.
And in future we also shouldn't have a lot of new users of those functions.

> 
> LGTM
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
