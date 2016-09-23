Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id AEC9E28024B
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 10:42:06 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id t67so245127649ywg.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 07:42:06 -0700 (PDT)
Received: from mail-yw0-x244.google.com (mail-yw0-x244.google.com. [2607:f8b0:4002:c05::244])
        by mx.google.com with ESMTPS id p134si3085404ywp.82.2016.09.23.07.42.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 07:42:06 -0700 (PDT)
Received: by mail-yw0-x244.google.com with SMTP id u82so6015000ywc.2
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 07:42:06 -0700 (PDT)
Date: Fri, 23 Sep 2016 10:42:02 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/1] lib/ioremap.c: avoid endless loop under ioremapping
 page unaligned ranges
Message-ID: <20160923144202.GA31387@htj.duckdns.org>
References: <57E20A69.5010206@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57E20A69.5010206@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

Hello,

On Wed, Sep 21, 2016 at 12:19:53PM +0800, zijun_hu wrote:
> From: zijun_hu <zijun_hu@htc.com>
> 
> endless loop maybe happen if either of parameter addr and end is not
> page aligned for kernel API function ioremap_page_range()
> 
> in order to fix this issue and alert improper range parameters to user
> WARN_ON() checkup and rounding down range lower boundary are performed
> firstly, loop end condition within ioremap_pte_range() is optimized due
> to lack of relevant macro pte_addr_end()
> 
> Signed-off-by: zijun_hu <zijun_hu@htc.com>

Unfortunately, I can't see what the points are in this series of
patches.  Most seem to be gratuitous changes which don't address real
issues or improve anything.  "I looked at the code and realized that,
if the input were wrong, the function would misbehave" isn't good
enough a reason.  What's next?  Are we gonna harden all pointer taking
functions too?

For internal functions, we don't by default do input sanitization /
sanity check.  There sure are cases where doing so is beneficial but
reading a random function and thinking "oh this combo of parameters
can make it go bonkers" isn't the right approach for it.  We end up
with cruft and code changes which nobody needed in the first place and
can easily introduce actual real bugs in the process.

It'd be an a lot more productive use of time and effort for everyone
involved if the work is around actual issues.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
