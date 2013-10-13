Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id CD1BA6B0037
	for <linux-mm@kvack.org>; Sun, 13 Oct 2013 15:54:12 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld10so6587402pab.8
        for <linux-mm@kvack.org>; Sun, 13 Oct 2013 12:54:12 -0700 (PDT)
Received: by mail-qa0-f45.google.com with SMTP id ii20so1774617qab.4
        for <linux-mm@kvack.org>; Sun, 13 Oct 2013 12:54:10 -0700 (PDT)
Date: Sun, 13 Oct 2013 15:54:06 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 09/23] mm/init: Use memblock apis for early memory
 allocations
Message-ID: <20131013195406.GC18075@htj.dyndns.org>
References: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
 <1381615146-20342-10-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381615146-20342-10-git-send-email-santosh.shilimkar@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: yinghai@kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, grygorii.strashko@ti.com, Andrew Morton <akpm@linux-foundation.org>

On Sat, Oct 12, 2013 at 05:58:52PM -0400, Santosh Shilimkar wrote:
> Switch to memblock interfaces for early memory allocator

When posting actual (non-RFC) patches later, please cc the maintainers
of the target subsystem and briefly explain why the new interface is
needed and that this doesn't change visible behavior.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
