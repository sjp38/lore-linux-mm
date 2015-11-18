Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id 16BD16B0257
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 13:33:48 -0500 (EST)
Received: by ykdv3 with SMTP id v3so79418421ykd.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 10:33:47 -0800 (PST)
Received: from mail-yk0-x22e.google.com (mail-yk0-x22e.google.com. [2607:f8b0:4002:c07::22e])
        by mx.google.com with ESMTPS id o64si3751798ywb.272.2015.11.18.10.33.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 10:33:47 -0800 (PST)
Received: by ykfs79 with SMTP id s79so79958561ykf.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 10:33:47 -0800 (PST)
Date: Wed, 18 Nov 2015 13:33:44 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] writeback: initialize m_dirty to avoid compile warning
Message-ID: <20151118183344.GD11496@mtj.duckdns.org>
References: <1447439201-32009-1-git-send-email-yang.shi@linaro.org>
 <20151117153855.99d2acd0568d146c29defda5@linux-foundation.org>
 <20151118181142.GC11496@mtj.duckdns.org>
 <564CC314.1090904@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <564CC314.1090904@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

Hello,

On Wed, Nov 18, 2015 at 10:27:32AM -0800, Shi, Yang wrote:
> >This was the main reason the code was structured the way it is.  If
> >cgroup writeback is not enabled, any derefs of mdtc variables should
> >trigger warnings.  Ugh... I don't know.  Compiler really should be
> >able to tell this much.
> 
> Thanks for the explanation. It sounds like a compiler problem.
> 
> If you think it is still good to cease the compile warning, maybe we could

If this is gonna be a problem with new gcc versions, I don't think we
have any other options. :(

> just assign it to an insane value as what Andrew suggested, maybe
> 0xdeadbeef.

I'd just keep it at zero.  Whatever we do, the effect is gonna be
difficult to track down - it's not gonna blow up in an obvious way.
Can you please add a comment tho explaining that this is to work
around compiler deficiency?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
