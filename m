Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 72D4A6B0069
	for <linux-mm@kvack.org>; Sun, 19 Oct 2014 15:56:01 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id 10so2878675lbg.32
        for <linux-mm@kvack.org>; Sun, 19 Oct 2014 12:56:00 -0700 (PDT)
Received: from asavdk3.altibox.net (asavdk3.altibox.net. [109.247.116.14])
        by mx.google.com with ESMTPS id p8si11499038lag.62.2014.10.19.12.55.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Oct 2014 12:55:59 -0700 (PDT)
Date: Sun, 19 Oct 2014 21:55:53 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: unaligned accesses in SLAB etc.
Message-ID: <20141019195553.GA11365@ravnborg.org>
References: <20141018.135907.356113264227709132.davem@davemloft.net>
 <20141018.142335.1935310766779155342.davem@davemloft.net>
 <20141019153219.GA10644@ravnborg.org>
 <20141019.132737.1392053813844289431.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141019.132737.1392053813844289431.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: mroos@linux.ee, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

On Sun, Oct 19, 2014 at 01:27:37PM -0400, David Miller wrote:
> From: Sam Ravnborg <sam@ravnborg.org>
> Date: Sun, 19 Oct 2014 17:32:20 +0200
> 
> > This part:
> > 
> >> +		__attribute__ ((aligned(64)));
> > 
> > Could be written as __aligned(64)
> 
> I'll try to remember to sweep this up in sparc-next, thanks Sam.
> 
> We probably use this long-hand form in a lot of other places in
> the sparc code too, so I'll try to do a full sweep.

Another related one would be a full sweep of "__asm__ __volatile__"
to the shorter version "asm volatile".

The latter is used in a few places in sparc already - so toolchain supports it.

I got hits in:
include/asm/irqflags_32.h:      asm volatile("rd        %%psr, %0" : "=r" (flags));
include/asm/processor_64.h:#define cpu_relax()  asm volatile("\n99:\n\t"                        \
kernel/kprobes.c:       asm volatile(".global kretprobe_trampoline\n"

But this would touch 93 files. Thats too much crunch :-(

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
