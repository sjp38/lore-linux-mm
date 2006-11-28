Received: by ug-out-1314.google.com with SMTP id s2so1221469uge
        for <linux-mm@kvack.org>; Tue, 28 Nov 2006 00:00:35 -0800 (PST)
Message-ID: <84144f020611280000w26d74321i2804b3d04b87762@mail.gmail.com>
Date: Tue, 28 Nov 2006 10:00:35 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [RFC] Extract kmalloc.h and slob.h from slab.h
In-Reply-To: <Pine.LNX.4.64.0611272229290.6012@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0611272229290.6012@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On 11/28/06, Christoph Lameter <clameter@sgi.com> wrote:
> @@ -0,0 +1,221 @@
> +#ifndef _LINUX_KMALLOC_H
> +#define        _LINUX_KMALLOC_H
> +
> +#include <linux/gfp.h>
> +#include <asm/page.h>          /* kmalloc_sizes.h needs PAGE_SIZE */
> +#include <asm/cache.h>         /* kmalloc_sizes.h needs L1_CACHE_BYTES */
> +
> +#ifdef __KERNEL__

This is an in-kernel header so why do we need the above #ifdef clause?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
