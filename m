Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 57AE56B0032
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 18:18:05 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so57795157pab.6
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 15:18:05 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id jk8si15345697pbd.89.2015.01.30.15.18.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 15:18:04 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id et14so57863841pad.4
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 15:18:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150130134525.d9e4ddf09f3c52f710e4a6f4@linux-foundation.org>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-18-git-send-email-a.ryabinin@samsung.com>
	<20150129151332.3f87c0b2e335afd88af33e08@linux-foundation.org>
	<54CBC3A1.5040505@samsung.com>
	<20150130134525.d9e4ddf09f3c52f710e4a6f4@linux-foundation.org>
Date: Sat, 31 Jan 2015 03:18:04 +0400
Message-ID: <CAPAsAGzmu8nXJrVgmFNkyPaYBVvK9OgJNu8WBgwsBHWsprfs4g@mail.gmail.com>
Subject: Re: [PATCH v10 17/17] kasan: enable instrumentation of global variables
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Rusty Russell <rusty@rustcorp.com.au>, Michal Marek <mmarek@suse.cz>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>

2015-01-31 0:45 GMT+03:00 Andrew Morton <akpm@linux-foundation.org>:
> On Fri, 30 Jan 2015 20:47:13 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
>
>> >> +struct kasan_global {
>> >> +  const void *beg;                /* Address of the beginning of the global variable. */
>> >> +  size_t size;                    /* Size of the global variable. */
>> >> +  size_t size_with_redzone;       /* Size of the variable + size of the red zone. 32 bytes aligned */
>> >> +  const void *name;
>> >> +  const void *module_name;        /* Name of the module where the global variable is declared. */
>> >> +  unsigned long has_dynamic_init; /* This needed for C++ */
>> >
>> > This can be removed?
>> >
>>
>> No, compiler dictates layout of this struct. That probably deserves a comment.
>
> I see.  A link to the relevant gcc doc would be good.
>

There is no doc, only gcc source code.

> Perhaps the compiler provides a header file so clients of this feature
> don't need to write their own?
>

Nope.
Actually, we are the only client of this feature outside gcc code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
