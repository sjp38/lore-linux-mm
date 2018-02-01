Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 111606B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 14:58:06 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id x2so4082633plv.16
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 11:58:06 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id l90si269035pfb.248.2018.02.01.11.58.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 01 Feb 2018 11:58:04 -0800 (PST)
Date: Thu, 1 Feb 2018 11:57:57 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm/kasan: Don't vfree() nonexistent vm_area.
Message-ID: <20180201195757.GC20742@bombadil.infradead.org>
References: <12c9e499-9c11-d248-6a3f-14ec8c4e07f1@molgen.mpg.de>
 <20180201163349.8700-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180201163349.8700-1-aryabinin@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Menzel <pmenzel+linux-kasan-dev@molgen.mpg.de>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Thu, Feb 01, 2018 at 07:33:49PM +0300, Andrey Ryabinin wrote:
> +	case MEM_OFFLINE: {
> +		struct vm_struct *vm;
> +
> +		/*
> +		 * Only hot-added memory have vm_area. Freeing shadow
> +		 * mapped during boot would be tricky, so we'll just
> +		 * have to keep it.
> +		 */
> +		vm = find_vm_area((void *)shadow_start);
> +		if (vm)
> +			vfree((void *)shadow_start);
> +	}

This looks like a complicated way to spell 'is_vmalloc_addr' ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
