Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7D8476B025E
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 06:39:44 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so36027727wib.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 03:39:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m6si8586029wiw.1.2015.07.17.03.39.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 17 Jul 2015 03:39:43 -0700 (PDT)
Date: Fri, 17 Jul 2015 11:39:39 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm/rmap: disable preemption for trace_tlb_flush()
Message-ID: <20150717103939.GD2561@suse.de>
References: <1437113574-2047-1-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1437113574-2047-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Fri, Jul 17, 2015 at 03:12:54PM +0900, Sergey Senozhatsky wrote:
> tlb_flush contains TP_CONDITION(cpu_online(smp_processor_id()))
> which is better be executed with preemption disabled.
> 
> Move trace_tlb_flush(TLB_REMOTE_SHOOTDOWN) in try_to_unmap_flush()
> under get_cpu().
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Your patch is valid but Sasha also had sent an almost identicial fix a few
hours ago for identical reasons that Andrew picked up. Thanks for sending
it in.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
