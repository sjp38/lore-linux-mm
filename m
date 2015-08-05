Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 88B1E6B0254
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 13:19:07 -0400 (EDT)
Received: by pdco4 with SMTP id o4so21005885pdc.3
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 10:19:07 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com. [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id fu2si6218289pbb.175.2015.08.05.10.19.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 10:19:06 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so21225210pdr.2
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 10:19:06 -0700 (PDT)
Date: Wed, 5 Aug 2015 13:19:00 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] writeback: fix initial dirty limit
Message-ID: <20150805171900.GN17598@mtj.duckdns.org>
References: <1438794520-27414-1-git-send-email-rabin.vincent@axis.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438794520-27414-1-git-send-email-rabin.vincent@axis.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rabin Vincent <rabin.vincent@axis.com>
Cc: axboe@fb.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rabin Vincent <rabinv@axis.com>

On Wed, Aug 05, 2015 at 07:08:40PM +0200, Rabin Vincent wrote:
> The initial value of global_wb_domain.dirty_limit set by
> writeback_set_ratelimit() is zeroed out by the memset in
> wb_domain_init().
> 
> Signed-off-by: Rabin Vincent <rabin.vincent@axis.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
