Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB516B0035
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 10:23:07 -0400 (EDT)
Received: by mail-qa0-f43.google.com with SMTP id i13so8758629qae.30
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 07:23:07 -0700 (PDT)
Received: from mail-qa0-x235.google.com (mail-qa0-x235.google.com [2607:f8b0:400d:c00::235])
        by mx.google.com with ESMTPS id h5si13712463qab.21.2014.09.29.07.23.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 07:23:06 -0700 (PDT)
Received: by mail-qa0-f53.google.com with SMTP id cm18so8941429qab.40
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 07:23:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJOtW+7UJQ2=66vELbyfXumQ=c9LknRAzXmd6Z6ea7i4oy6FwA@mail.gmail.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1411562649-28231-1-git-send-email-a.ryabinin@samsung.com>
 <54259BD4.8090508@oracle.com> <CACT4Y+Y0fzbs4DPt3n30R33cYqXEZ8E86tzCfzL6RUE9f+-r=w@mail.gmail.com>
 <CAPAsAGyDpnhpMquXi-K4wdDEbj-5W44uJLircsok7ziOO_m66g@mail.gmail.com>
 <CACT4Y+bptO341KQAQMSzUVV22KsjuomdTeDip=HaHJ3+1kvraQ@mail.gmail.com> <CAJOtW+7UJQ2=66vELbyfXumQ=c9LknRAzXmd6Z6ea7i4oy6FwA@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 29 Sep 2014 18:22:46 +0400
Message-ID: <CACT4Y+ZGXV_+J7sR-6_HX5eAOWQAXw5gSvjh1rw_mCxt90iNtQ@mail.gmail.com>
Subject: Re: [PATCH v3 00/13] Kernel address sanitizer - runtime memory debugger.
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yuri Gribov <tetra2005@gmail.com>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-kbuild@vger.kernel.org, x86@kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>

On Fri, Sep 26, 2014 at 10:48 PM, Yuri Gribov <tetra2005@gmail.com> wrote:
> On Fri, Sep 26, 2014 at 9:29 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> So in kernel we will need to support all API versions, and the
>> following looks like a much simpler way to identify current API
>> version:
>>> #if __GNUC__ == 5
>>> #define ASAN_V4
>
> What about having compiler(s) predefine some __SANITIZE_ADDRESS_ABI__
> macro for this? Hacking on __GNUC__ may not work given the zoo of GCC
> versions out there (FSF, Linaro, vendor toolchains, etc.)?

I don't have strong preference here... well, actually just not competent :)

But on the second though... what do we want to do with pre-build
modules? Can you envision that somebody distributes binary modules
built with asan?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
