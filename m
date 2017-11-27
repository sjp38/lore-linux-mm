Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 206256B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 15:54:25 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id j12so10070065qtc.20
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 12:54:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a125sor19144908qkd.95.2017.11.27.12.54.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 12:54:24 -0800 (PST)
Date: Mon, 27 Nov 2017 12:54:21 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: mm/percpu.c: use smarter memory allocation for struct
 pcpu_alloc_info (crisv32 hang)
Message-ID: <20171127205421.GR983427@devbig577.frc2.facebook.com>
References: <nycvar.YSQ.7.76.1710031731130.5407@knanqh.ubzr>
 <20171118182542.GA23928@roeck-us.net>
 <20171127194105.GM983427@devbig577.frc2.facebook.com>
 <nycvar.YSQ.7.76.1711271515540.5925@knanqh.ubzr>
 <20171127203335.GQ983427@devbig577.frc2.facebook.com>
 <nycvar.YSQ.7.76.1711271534590.5925@knanqh.ubzr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YSQ.7.76.1711271534590.5925@knanqh.ubzr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Guenter Roeck <linux@roeck-us.net>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, linux-cris-kernel@axis.com

Hello, Nicolas.

On Mon, Nov 27, 2017 at 03:51:04PM -0500, Nicolas Pitre wrote:
> Subject: percpu: hack to let the CRIS architecture to boot until they clean up
> 
> Commit 438a506180 ("percpu: don't forget to free the temporary struct 
> pcpu_alloc_info") uncovered a problem on the CRIS architecture where
> the bootmem allocator is initialized with virtual addresses. Given it 
> has:
> 
>     #define __va(x) ((void *)((unsigned long)(x) | 0x80000000))
> 
> then things just work out because the end result is the same whether you
> give this a physical or a virtual address.
> 
> Untill you call memblock_free_early(__pa(address)) that is, because
> values from __pa() don't match with the virtual addresses stuffed in the
> bootmem allocator anymore.
> 
> Avoid freeing the temporary pcpu_alloc_info memory on that architecture
> until they fix things up to let the kernel boot like it did before.
> 
> Signed-off-by: Nicolas Pitre <nico@linaro.org>

This totally works for me.  Replaced the revert with this one.

Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
