Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 842486B0069
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 19:51:29 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id w69so62059798qka.6
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 16:51:29 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id g1si8050864qtb.145.2016.10.13.16.51.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Oct 2016 16:51:28 -0700 (PDT)
Subject: Re: [RFC v2 PATCH] mm/percpu.c: simplify grouping CPU algorithm
References: <701fa92a-026b-f30b-833c-a5e61eab6549@zoho.com>
 <20161013233722.GF32534@mtj.duckdns.org>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <b1e98606-be69-0dd6-0a50-1b19e6237dc5@zoho.com>
Date: Fri, 14 Oct 2016 07:49:44 +0800
MIME-Version: 1.0
In-Reply-To: <20161013233722.GF32534@mtj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, cl@linux.com

On 2016/10/14 7:37, Tejun Heo wrote:
> Hello, Zijun.
> 
> On Tue, Oct 11, 2016 at 08:48:45PM +0800, zijun_hu wrote:
>> compared with the original algorithm theoretically and practically, the
>> new one educes the same grouping results, besides, it is more effective,
>> simpler and easier to understand.
> 
> If the original code wasn't broken and the new code produces the same
> output, I'd really not mess with this code.  There simply is no upside
> to messing with this code.  It's run once during boot and never a
> noticeable contributor of boot overhead.  Maybe the new code is a bit
> simpler and more efficient but the actual benefit is so small that any
> risk would outweigh it.
> 
> Thanks.
>
the main intent of this change is making the CPU grouping algorithm more
easily to understand, especially, for newcomer for memory managements
take me as a example, i really take me a longer timer to understand it
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
