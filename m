Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id E157E900002
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 17:59:02 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id cc10so3547457wib.12
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 14:59:02 -0700 (PDT)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id na8si9832569wic.48.2014.07.09.14.59.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 14:59:02 -0700 (PDT)
Received: by mail-wi0-f176.google.com with SMTP id n3so3535953wiv.3
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 14:59:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <8761j6nr53.fsf@tassilo.jf.intel.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<53BDB1D6.1090605@intel.com>
	<8761j6nr53.fsf@tassilo.jf.intel.com>
Date: Wed, 9 Jul 2014 23:59:01 +0200
Message-ID: <CAOMGZ=Fmqg6MWyx3NygqVmYiqw=npkPQrO9ifhF489bq5Gxz4A@mail.gmail.com>
Subject: Re: [RFC/PATCH RESEND -next 00/21] Address sanitizer for kernel
 (kasan) - dynamic memory error detector.
From: Vegard Nossum <vegard.nossum@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, kbuild <linux-kbuild@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, x86 maintainers <x86@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On 9 July 2014 23:44, Andi Kleen <andi@firstfloor.org> wrote:
> Dave Hansen <dave.hansen@intel.com> writes:
>>
>> You're also claiming that "KASAN is better than all of
>
> better as in finding more bugs, but surely not better as in
> "do so with less overhead"
>
>> CONFIG_DEBUG_PAGEALLOC".  So should we just disallow (or hide)
>> DEBUG_PAGEALLOC on kernels where KASAN is available?
>
> I don't think DEBUG_PAGEALLOC/SLUB debug and kasan really conflict.
>
> DEBUG_PAGEALLOC/SLUB is "much lower overhead but less bugs found".
> KASAN is "slow but thorough" There are niches for both.
>
> But I could see KASAN eventually deprecating kmemcheck, which
> is just incredible slow.

FWIW, I definitely agree with this -- if KASAN can do everything that
kmemcheck can, it is no doubt the right way forward.


Vegard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
