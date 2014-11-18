Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 034E96B006C
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 16:10:26 -0500 (EST)
Received: by mail-oi0-f49.google.com with SMTP id i138so2033607oig.22
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 13:10:25 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id o5si25729017oig.56.2014.11.18.13.10.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Nov 2014 13:10:25 -0800 (PST)
Message-ID: <546BB58A.4080209@oracle.com>
Date: Tue, 18 Nov 2014 16:09:30 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 00/11] Kernel address sanitizer - runtime memory debugger.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>	<1415199241-5121-1-git-send-email-a.ryabinin@samsung.com>	<5461B906.1040803@samsung.com> <20141118125843.434c216540def495d50f3a45@linux-foundation.org>
In-Reply-To: <20141118125843.434c216540def495d50f3a45@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org

On 11/18/2014 03:58 PM, Andrew Morton wrote:
> On Tue, 11 Nov 2014 10:21:42 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> 
>> Hi Andrew,
>>
>> Now we have stable GCC(4.9.2) which supports kasan and from my point of view patchset is ready for merging.
>> I could have sent v7 (it's just rebased v6), but I see no point in doing that and bothering people,
>> unless you are ready to take it.
> 
> It's a huge pile of tricky code we'll need to maintain.  To justify its
> inclusion I think we need to be confident that kasan will find a
> significant number of significant bugs that
> kmemcheck/debug_pagealloc/slub_debug failed to detect.
> 
> How do we get that confidence?  I've seen a small number of
> minorish-looking kasan-detected bug reports go past, maybe six or so. 
> That's in a 20-year-old code base, so one new minor bug discovered per
> three years?  Not worth it!

It's worth noting here that not all bugs discovered by kasan belong to
the -mm tree. Bugs which are more severe, such as:

	http://openwall.com/lists/oss-security/2014/07/17/1

Are the result of fuzzing with kasan. So while it's indeed not a huge number,
it's way more than 6 and not only minor issues.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
