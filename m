Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0ED196B006C
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 16:15:33 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id z12so10789887wgg.1
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 13:15:32 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id cw3si23030534wib.52.2014.11.18.13.15.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Nov 2014 13:15:32 -0800 (PST)
Date: Tue, 18 Nov 2014 22:15:31 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v6 00/11] Kernel address sanitizer - runtime memory
 debugger.
Message-ID: <20141118211531.GH12538@two.firstfloor.org>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1415199241-5121-1-git-send-email-a.ryabinin@samsung.com>
 <5461B906.1040803@samsung.com>
 <20141118125843.434c216540def495d50f3a45@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141118125843.434c216540def495d50f3a45@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org

> It's a huge pile of tricky code we'll need to maintain.  To justify its
> inclusion I think we need to be confident that kasan will find a
> significant number of significant bugs that
> kmemcheck/debug_pagealloc/slub_debug failed to detect.

I would put it differently. kmemcheck is effectively too slow to run
regularly. kasan is much faster and covers most of kmemcheck.

So I would rather see it as a more practical replacement to
kmemcheck, not an addition.

> How do we get that confidence?  I've seen a small number of
> minorish-looking kasan-detected bug reports go past, maybe six or so. 
> That's in a 20-year-old code base, so one new minor bug discovered per
> three years?  Not worth it!
> 
> Presumably more bugs will be exposed as more people use kasan on
> different kernel configs, but will their number and seriousness justify
> the maintenance effort?

I would expect so. It's also about saving developer time.

IMHO getting better tools like this is the only way to keep
up with growing complexity.

> If kasan will permit us to remove kmemcheck/debug_pagealloc/slub_debug
> then that tips the balance a little.  What's the feasibility of that?

Maybe removing kmemcheck. slub_debug/debug_pagealloc are simple, and are in
different niches (lower overhead debugging)

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
