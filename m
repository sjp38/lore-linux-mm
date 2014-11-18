Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 999066B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 16:32:57 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so5132628pab.2
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 13:32:57 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id a10si16642252pdp.168.2014.11.18.13.32.55
        for <linux-mm@kvack.org>;
        Tue, 18 Nov 2014 13:32:56 -0800 (PST)
Message-ID: <546BBAE2.306@intel.com>
Date: Tue, 18 Nov 2014 13:32:18 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 00/11] Kernel address sanitizer - runtime memory debugger.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1415199241-5121-1-git-send-email-a.ryabinin@samsung.com> <5461B906.1040803@samsung.com> <20141118125843.434c216540def495d50f3a45@linux-foundation.org> <20141118211531.GH12538@two.firstfloor.org>
In-Reply-To: <20141118211531.GH12538@two.firstfloor.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org

On 11/18/2014 01:15 PM, Andi Kleen wrote:
>> > If kasan will permit us to remove kmemcheck/debug_pagealloc/slub_debug
>> > then that tips the balance a little.  What's the feasibility of that?
> Maybe removing kmemcheck. slub_debug/debug_pagealloc are simple, and are in
> different niches (lower overhead debugging)

Yeah, slub_debug can be turned on at runtime in production kernels so
it's in a completely different category.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
