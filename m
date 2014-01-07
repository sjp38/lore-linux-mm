Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id F2A236B004D
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 10:19:46 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id k4so640692qaq.8
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 07:19:46 -0800 (PST)
Received: from mail-qe0-x22e.google.com (mail-qe0-x22e.google.com [2607:f8b0:400d:c02::22e])
        by mx.google.com with ESMTPS id g6si593804qab.55.2014.01.07.07.19.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 07:19:46 -0800 (PST)
Received: by mail-qe0-f46.google.com with SMTP id a11so451824qen.5
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 07:19:45 -0800 (PST)
Date: Tue, 7 Jan 2014 10:19:42 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/2] mm, nobootmem: Add return value check in
 __alloc_memory_core_early()
Message-ID: <20140107151942.GA3231@htj.dyndns.org>
References: <1389107774-54978-1-git-send-email-phacht@linux.vnet.ibm.com>
 <1389107774-54978-2-git-send-email-phacht@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389107774-54978-2-git-send-email-phacht@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, jiang.liu@huawei.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, tangchen@cn.fujitsu.com, toshi.kani@hp.com

On Tue, Jan 07, 2014 at 04:16:13PM +0100, Philipp Hachtmann wrote:
> When memblock_reserve() fails because memblock.reserved.regions cannot
> be resized, the caller (e.g. alloc_bootmem()) is not informed of the
> failed allocation. Therefore alloc_bootmem() silently returns the same
> pointer again and again.
> This patch adds a check for the return value of memblock_reserve() in
> __alloc_memory_core().
> 
> Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>

Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
