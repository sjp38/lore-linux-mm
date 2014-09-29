Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 47C066B003C
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 10:34:50 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fb1so5636028pad.25
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 07:34:50 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id pd4si23224072pdb.173.2014.09.29.07.34.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 29 Sep 2014 07:34:48 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NCO0056M3AKI090@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 29 Sep 2014 15:37:32 +0100 (BST)
Message-id: <54296C62.2080604@samsung.com>
Date: Mon, 29 Sep 2014 18:27:46 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC PATCH v3 13/13] kasan: introduce inline instrumentation
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1411562649-28231-1-git-send-email-a.ryabinin@samsung.com>
 <1411562649-28231-14-git-send-email-a.ryabinin@samsung.com>
 <CACT4Y+bTXPzYH+TMjM9-NyVajZms8zKdEMMLDPvOKvRSoD8tog@mail.gmail.com>
 <CAPAsAGzDWQ6LKN1RN6u0cv6eTVfxgRT6NCpGA08dC6dnDiUKmA@mail.gmail.com>
 <CACT4Y+ZVPV51vBDKTQ-snQ360kTc6axNS1g_02EA0h75Gqd3Bw@mail.gmail.com>
In-reply-to: 
 <CACT4Y+ZVPV51vBDKTQ-snQ360kTc6axNS1g_02EA0h75Gqd3Bw@mail.gmail.com>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Marek <mmarek@suse.cz>

On 09/29/2014 06:28 PM, Dmitry Vyukov wrote:
> On Fri, Sep 26, 2014 at 9:33 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
>> 2014-09-26 21:18 GMT+04:00 Dmitry Vyukov <dvyukov@google.com>:
>>>
>>> Yikes!
>>> So this works during bootstrap, for user memory accesses, valloc
>>> memory, etc, right?
>>>
>>
>> Yes, this works. Userspace memory access in instrumented code will
>> produce general protection fault,
>> so it won't be unnoticed.
> 
> 
> Great!
> What happens during early bootstrap when shadow is not mapped yet?
> 

Shadow mapped very early. Any instrumented code executes only after shadow mapped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
