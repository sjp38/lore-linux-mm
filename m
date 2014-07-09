Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id E1CDD900002
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 17:45:11 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so9644281pde.38
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 14:45:11 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id d10si7803334pdp.155.2014.07.09.14.45.09
        for <linux-mm@kvack.org>;
        Wed, 09 Jul 2014 14:45:10 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC/PATCH RESEND -next 00/21] Address sanitizer for kernel (kasan) - dynamic memory error detector.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<53BDB1D6.1090605@intel.com>
Date: Wed, 09 Jul 2014 14:44:56 -0700
In-Reply-To: <53BDB1D6.1090605@intel.com> (Dave Hansen's message of "Wed, 09
	Jul 2014 14:19:18 -0700")
Message-ID: <8761j6nr53.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

Dave Hansen <dave.hansen@intel.com> writes:
>
> You're also claiming that "KASAN is better than all of

better as in finding more bugs, but surely not better as in
"do so with less overhead"

> CONFIG_DEBUG_PAGEALLOC".  So should we just disallow (or hide)
> DEBUG_PAGEALLOC on kernels where KASAN is available?

I don't think DEBUG_PAGEALLOC/SLUB debug and kasan really conflict.

DEBUG_PAGEALLOC/SLUB is "much lower overhead but less bugs found".
KASAN is "slow but thorough" There are niches for both.

But I could see KASAN eventually deprecating kmemcheck, which
is just incredible slow.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
