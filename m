Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7F509900002
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 17:19:40 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id hz1so9772231pad.24
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 14:19:40 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id gm10si46901666pac.220.2014.07.09.14.19.38
        for <linux-mm@kvack.org>;
        Wed, 09 Jul 2014 14:19:39 -0700 (PDT)
Message-ID: <53BDB1D6.1090605@intel.com>
Date: Wed, 09 Jul 2014 14:19:18 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH RESEND -next 00/21] Address sanitizer for kernel (kasan)
 - dynamic memory error detector.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
In-Reply-To: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

This is totally self-serving (and employer-serving), but has anybody
thought about this large collection of memory debugging tools that we
are growing?  It helps to have them all in the same places in the menus
(thanks for adding it to Memory Debugging, btw!).

But, this gives us at least four things that overlap with kasan's
features on some level.  Each of these has its own advantages and
disadvantages, of course:

1. DEBUG_PAGEALLOC
2. SLUB debugging / DEBUG_OBJECTS
3. kmemcheck
4. kasan
... and there are surely more coming down pike.  Like Intel MPX:

> https://software.intel.com/en-us/articles/introduction-to-intel-memory-protection-extensions

Or, do we just keep adding these overlapping tools and their associated
code over and over and fragment their user bases?

You're also claiming that "KASAN is better than all of
CONFIG_DEBUG_PAGEALLOC".  So should we just disallow (or hide)
DEBUG_PAGEALLOC on kernels where KASAN is available?

Maybe we just need to keep these out of mainline and make Andrew carry
it in -mm until the end of time. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
