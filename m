Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 02E166B0069
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 20:33:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u84so93602353pfj.6
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 17:33:15 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id dj10si13679348pad.195.2016.10.13.17.33.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 17:33:15 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id 128so6029368pfz.1
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 17:33:15 -0700 (PDT)
Date: Thu, 13 Oct 2016 20:33:13 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 PATCH] mm/percpu.c: simplify grouping CPU algorithm
Message-ID: <20161014003313.GI32534@mtj.duckdns.org>
References: <701fa92a-026b-f30b-833c-a5e61eab6549@zoho.com>
 <20161013233722.GF32534@mtj.duckdns.org>
 <b1e98606-be69-0dd6-0a50-1b19e6237dc5@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b1e98606-be69-0dd6-0a50-1b19e6237dc5@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, cl@linux.com

Hello,

On Fri, Oct 14, 2016 at 07:49:44AM +0800, zijun_hu wrote:
> the main intent of this change is making the CPU grouping algorithm more
> easily to understand, especially, for newcomer for memory managements
> take me as a example, i really take me a longer timer to understand it

If the new code is easier to understand, it's only so marginally.  It
just isn't worth the effort or risk.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
