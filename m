Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 84DB06B0005
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 12:20:40 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id b3so4986476plr.23
        for <linux-mm@kvack.org>; Fri, 02 Feb 2018 09:20:40 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t13-v6si2205838plr.411.2018.02.02.09.20.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 02 Feb 2018 09:20:39 -0800 (PST)
Date: Fri, 2 Feb 2018 09:20:27 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm/kasan: Don't vfree() nonexistent vm_area.
Message-ID: <20180202172027.GB16840@bombadil.infradead.org>
References: <12c9e499-9c11-d248-6a3f-14ec8c4e07f1@molgen.mpg.de>
 <20180201163349.8700-1-aryabinin@virtuozzo.com>
 <20180201195757.GC20742@bombadil.infradead.org>
 <e1cf8e8e-4cc4-ff4f-92e1-f6fcf373c67f@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e1cf8e8e-4cc4-ff4f-92e1-f6fcf373c67f@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Menzel <pmenzel+linux-kasan-dev@molgen.mpg.de>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Thu, Feb 01, 2018 at 11:22:55PM +0300, Andrey Ryabinin wrote:
> >> +		vm = find_vm_area((void *)shadow_start);
> >> +		if (vm)
> >> +			vfree((void *)shadow_start);
> >> +	}
> > 
> > This looks like a complicated way to spell 'is_vmalloc_addr' ...
> > 
> 
> It's not. shadow_start is never vmalloc address.

I'm confused.  How can you call vfree() on something that isn't a vmalloc
address?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
