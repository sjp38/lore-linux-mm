Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3F3E16B03A3
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 04:05:28 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v44so14765861wrc.9
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 01:05:28 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 4si7070026wrr.224.2017.03.31.01.05.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 31 Mar 2017 01:05:27 -0700 (PDT)
Date: Fri, 31 Mar 2017 10:05:15 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 2/4] x86/ldt: use vfree() instead of vfree_atomic()
In-Reply-To: <20170330102719.13119-2-aryabinin@virtuozzo.com>
Message-ID: <alpine.DEB.2.20.1703311005030.1780@nanos>
References: <20170330102719.13119-1-aryabinin@virtuozzo.com> <20170330102719.13119-2-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: akpm@linux-foundation.org, penguin-kernel@I-love.SAKURA.ne.jp, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, hpa@zytor.com, chris@chris-wilson.co.uk, hch@lst.de, mingo@elte.hu, jszhang@marvell.com, joelaf@google.com, joaodias@google.com, willy@infradead.org

On Thu, 30 Mar 2017, Andrey Ryabinin wrote:

> vfree() can be used in any atomic context now, thus there is no point
> in vfree_atomic().
> This reverts commit 8d5341a6260a ("x86/ldt: use vfree_atomic()
> to free ldt entries")
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
