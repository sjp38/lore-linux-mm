Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id AC84A6B0032
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 16:45:27 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id kx10so57001070pab.11
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 13:45:27 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ue3si15124830pab.125.2015.01.30.13.45.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Jan 2015 13:45:26 -0800 (PST)
Date: Fri, 30 Jan 2015 13:45:25 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 17/17] kasan: enable instrumentation of global
 variables
Message-Id: <20150130134525.d9e4ddf09f3c52f710e4a6f4@linux-foundation.org>
In-Reply-To: <54CBC3A1.5040505@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-18-git-send-email-a.ryabinin@samsung.com>
	<20150129151332.3f87c0b2e335afd88af33e08@linux-foundation.org>
	<54CBC3A1.5040505@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Rusty Russell <rusty@rustcorp.com.au>, Michal Marek <mmarek@suse.cz>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>

On Fri, 30 Jan 2015 20:47:13 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:

> >> +struct kasan_global {
> >> +	const void *beg;		/* Address of the beginning of the global variable. */
> >> +	size_t size;			/* Size of the global variable. */
> >> +	size_t size_with_redzone;	/* Size of the variable + size of the red zone. 32 bytes aligned */
> >> +	const void *name;
> >> +	const void *module_name;	/* Name of the module where the global variable is declared. */
> >> +	unsigned long has_dynamic_init;	/* This needed for C++ */
> > 
> > This can be removed?
> > 
> 
> No, compiler dictates layout of this struct. That probably deserves a comment.

I see.  A link to the relevant gcc doc would be good.

Perhaps the compiler provides a header file so clients of this feature
don't need to write their own?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
