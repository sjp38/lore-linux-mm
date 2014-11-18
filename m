Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6C4D76B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 15:58:47 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id y20so8120287ier.0
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 12:58:47 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d7si11455237igl.52.2014.11.18.12.58.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Nov 2014 12:58:46 -0800 (PST)
Date: Tue, 18 Nov 2014 12:58:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 00/11] Kernel address sanitizer - runtime memory
 debugger.
Message-Id: <20141118125843.434c216540def495d50f3a45@linux-foundation.org>
In-Reply-To: <5461B906.1040803@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1415199241-5121-1-git-send-email-a.ryabinin@samsung.com>
	<5461B906.1040803@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org

On Tue, 11 Nov 2014 10:21:42 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:

> Hi Andrew,
> 
> Now we have stable GCC(4.9.2) which supports kasan and from my point of view patchset is ready for merging.
> I could have sent v7 (it's just rebased v6), but I see no point in doing that and bothering people,
> unless you are ready to take it.

It's a huge pile of tricky code we'll need to maintain.  To justify its
inclusion I think we need to be confident that kasan will find a
significant number of significant bugs that
kmemcheck/debug_pagealloc/slub_debug failed to detect.

How do we get that confidence?  I've seen a small number of
minorish-looking kasan-detected bug reports go past, maybe six or so. 
That's in a 20-year-old code base, so one new minor bug discovered per
three years?  Not worth it!

Presumably more bugs will be exposed as more people use kasan on
different kernel configs, but will their number and seriousness justify
the maintenance effort?

If kasan will permit us to remove kmemcheck/debug_pagealloc/slub_debug
then that tips the balance a little.  What's the feasibility of that?


Sorry to play the hardass here, but someone has to ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
