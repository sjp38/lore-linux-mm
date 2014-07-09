Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id F319E82965
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 19:33:13 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id v10so9722861pde.20
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 16:33:13 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id hn2si47050557pbc.256.2014.07.09.16.33.11
        for <linux-mm@kvack.org>;
        Wed, 09 Jul 2014 16:33:12 -0700 (PDT)
Message-ID: <53BDD135.1000105@intel.com>
Date: Wed, 09 Jul 2014 16:33:09 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH RESEND -next 00/21] Address sanitizer for kernel (kasan)
 - dynamic memory error detector.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>	<53BDB1D6.1090605@intel.com>	<8761j6nr53.fsf@tassilo.jf.intel.com> <CAOMGZ=Fmqg6MWyx3NygqVmYiqw=npkPQrO9ifhF489bq5Gxz4A@mail.gmail.com>
In-Reply-To: <CAOMGZ=Fmqg6MWyx3NygqVmYiqw=npkPQrO9ifhF489bq5Gxz4A@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@gmail.com>, Andi Kleen <andi@firstfloor.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, kbuild <linux-kbuild@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, x86 maintainers <x86@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On 07/09/2014 02:59 PM, Vegard Nossum wrote:
>> > But I could see KASAN eventually deprecating kmemcheck, which
>> > is just incredible slow.
> FWIW, I definitely agree with this -- if KASAN can do everything that
> kmemcheck can, it is no doubt the right way forward.

That's very cool.  For what it's worth, the per-arch work does appear to
be pretty minimal and the things like the string function replacements
_should_ be able to be made generic.  Aren't the x86_32/x86_64 and arm
hooks pretty much copied-and-pasted?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
