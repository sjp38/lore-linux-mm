Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C445C6B0069
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 19:37:25 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 189so126434332ity.1
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 16:37:25 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id u6si9767366iod.178.2016.10.13.16.37.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 16:37:25 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id i85so2534147pfa.0
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 16:37:25 -0700 (PDT)
Date: Thu, 13 Oct 2016 19:37:22 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 PATCH] mm/percpu.c: simplify grouping CPU algorithm
Message-ID: <20161013233722.GF32534@mtj.duckdns.org>
References: <701fa92a-026b-f30b-833c-a5e61eab6549@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <701fa92a-026b-f30b-833c-a5e61eab6549@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: akpm@linux-foundation.org, zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com

Hello, Zijun.

On Tue, Oct 11, 2016 at 08:48:45PM +0800, zijun_hu wrote:
> compared with the original algorithm theoretically and practically, the
> new one educes the same grouping results, besides, it is more effective,
> simpler and easier to understand.

If the original code wasn't broken and the new code produces the same
output, I'd really not mess with this code.  There simply is no upside
to messing with this code.  It's run once during boot and never a
noticeable contributor of boot overhead.  Maybe the new code is a bit
simpler and more efficient but the actual benefit is so small that any
risk would outweigh it.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
