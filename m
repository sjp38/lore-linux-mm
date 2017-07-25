Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE07F6B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 14:24:04 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id e2so19130368qta.13
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:24:04 -0700 (PDT)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id k5si5473122qtd.504.2017.07.25.11.24.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 11:24:04 -0700 (PDT)
Received: by mail-qt0-x243.google.com with SMTP id l55so15645750qtl.3
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:24:04 -0700 (PDT)
Date: Tue, 25 Jul 2017 14:24:02 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 08/23] percpu: modify base_addr to be region specific
Message-ID: <20170725182401.GH18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-9-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-9-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:05PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> Originally, the first chunk was served by one or two chunks, each
> given a region they are responsible for. Despite this, the arithmetic
> was based off of the true base_addr of the chunk making it be overly
> inclusive.
> 
> This patch moves the base_addr of chunks that are responsible for the
> first chunk. The base_addr must remain page aligned to keep the
> address alignment correct, so it is the beginning of the region served
> page aligned down. start_offset holds where the region served begins
> from this new base_addr.
> 
> The corresponding percpu address checks are modified to be more specific
> as a result. The first chunk considers only the dynamic region and both
> first chunk and reserved chunk checks ignore the static region. The
> static region addresses should never be passed into the allocator. There
> is no impact here besides distinguishing the first chunk and making the
> checks specific.
> 
> The percpu pointer to physical address is left intact as addresses are
> not given out in the non-allocated portion of percpu memory.
> 
> nr_pages is added to pcpu_chunk to keep track of the size of the entire
> region served containing both start_offset and end_offset. This variable
> will be used to manage the bitmap allocator.
> 
> Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>

Reviewed-by: Josef Bacik <jbacik@fb.com>

Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
