Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0976B0033
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 10:15:33 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r18so5263313pgu.9
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 07:15:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z11sor3390046ite.135.2017.10.04.07.15.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Oct 2017 07:15:32 -0700 (PDT)
Date: Wed, 4 Oct 2017 07:15:28 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm/percpu.c: use smarter memory allocation for struct
 pcpu_alloc_info
Message-ID: <20171004141528.GO3301751@devbig577.frc2.facebook.com>
References: <nycvar.YSQ.7.76.1710031638450.5407@knanqh.ubzr>
 <20171003210540.GM3301751@devbig577.frc2.facebook.com>
 <nycvar.YSQ.7.76.1710031731130.5407@knanqh.ubzr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YSQ.7.76.1710031731130.5407@knanqh.ubzr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Tue, Oct 03, 2017 at 06:29:49PM -0400, Nicolas Pitre wrote:
> Subject: [PATCH] percpu: don't forget to free the temporary struct pcpu_alloc_info
> 
> Unlike the SMP case, the !SMP case does not free the memory for struct 
> pcpu_alloc_info allocated in setup_per_cpu_areas(). And to give it a 
> chance of being reused by the page allocator later, align it to a page 
> boundary just like its size.
> 
> Signed-off-by: Nicolas Pitre <nico@linaro.org>

Applied to percpu/for-4.15 w/ Dennis's ack.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
