Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 934536B003C
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 10:28:33 -0400 (EDT)
Received: by mail-qa0-f53.google.com with SMTP id cm18so8724571qab.26
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 07:28:33 -0700 (PDT)
Received: from mail-qg0-x229.google.com (mail-qg0-x229.google.com [2607:f8b0:400d:c04::229])
        by mx.google.com with ESMTPS id r12si5063678qag.121.2014.09.29.07.28.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 07:28:27 -0700 (PDT)
Received: by mail-qg0-f41.google.com with SMTP id f51so2294333qge.14
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 07:28:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPAsAGzDWQ6LKN1RN6u0cv6eTVfxgRT6NCpGA08dC6dnDiUKmA@mail.gmail.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1411562649-28231-1-git-send-email-a.ryabinin@samsung.com>
 <1411562649-28231-14-git-send-email-a.ryabinin@samsung.com>
 <CACT4Y+bTXPzYH+TMjM9-NyVajZms8zKdEMMLDPvOKvRSoD8tog@mail.gmail.com> <CAPAsAGzDWQ6LKN1RN6u0cv6eTVfxgRT6NCpGA08dC6dnDiUKmA@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 29 Sep 2014 18:28:06 +0400
Message-ID: <CACT4Y+ZVPV51vBDKTQ-snQ360kTc6axNS1g_02EA0h75Gqd3Bw@mail.gmail.com>
Subject: Re: [RFC PATCH v3 13/13] kasan: introduce inline instrumentation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Marek <mmarek@suse.cz>

On Fri, Sep 26, 2014 at 9:33 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
> 2014-09-26 21:18 GMT+04:00 Dmitry Vyukov <dvyukov@google.com>:
>>
>> Yikes!
>> So this works during bootstrap, for user memory accesses, valloc
>> memory, etc, right?
>>
>
> Yes, this works. Userspace memory access in instrumented code will
> produce general protection fault,
> so it won't be unnoticed.


Great!
What happens during early bootstrap when shadow is not mapped yet?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
