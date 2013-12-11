Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 677986B0069
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 17:10:51 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id md12so10771097pbc.21
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 14:10:51 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id u7si962963pbh.292.2013.12.11.14.10.49
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 14:10:50 -0800 (PST)
Date: Wed, 11 Dec 2013 14:10:40 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm/memblock: print phys_addr_t using %pa
Message-Id: <20131211141040.6a28d2f9173cab62727c8c9f@linux-foundation.org>
In-Reply-To: <1386776175-23779-2-git-send-email-grygorii.strashko@ti.com>
References: <1386776175-23779-1-git-send-email-grygorii.strashko@ti.com>
	<1386776175-23779-2-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Cc: santosh.shilimkar@ti.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>

On Wed, 11 Dec 2013 17:36:14 +0200 Grygorii Strashko <grygorii.strashko@ti.com> wrote:

> printk supports %pa format specifier to print phys_addr_t type values,
> so use it instead of %#010llx/0x%llx/0x%08lx and drop corresponding
> type casting.

This one needed some rework due to
http://ozlabs.org/~akpm/mmots/broken-out/memblock-numa-introduce-flags-field-into-memblock.patch,
but it was all pretty simple.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
