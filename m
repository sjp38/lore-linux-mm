Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id CAFE7280324
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 07:20:36 -0400 (EDT)
Received: by pdbqm3 with SMTP id qm3so60557457pdb.0
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 04:20:36 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id et2si18168121pbc.69.2015.07.17.04.20.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 04:20:36 -0700 (PDT)
Received: by padck2 with SMTP id ck2so59207680pad.0
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 04:20:35 -0700 (PDT)
Date: Fri, 17 Jul 2015 20:19:43 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] mm/rmap: disable preemption for trace_tlb_flush()
Message-ID: <20150717111943.GA636@swordfish>
References: <1437113574-2047-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20150717103939.GD2561@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150717103939.GD2561@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (07/17/15 11:39), Mel Gorman wrote:
> On Fri, Jul 17, 2015 at 03:12:54PM +0900, Sergey Senozhatsky wrote:
> > tlb_flush contains TP_CONDITION(cpu_online(smp_processor_id()))
> > which is better be executed with preemption disabled.
> > 
> > Move trace_tlb_flush(TLB_REMOTE_SHOOTDOWN) in try_to_unmap_flush()
> > under get_cpu().
> > 
> > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> 
> Your patch is valid but Sasha also had sent an almost identicial fix a few
> hours ago for identical reasons that Andrew picked up. Thanks for sending
> it in.

Oh, didn't know that. Thanks.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
