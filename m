Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0166B0254
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 19:51:49 -0500 (EST)
Received: by padhx2 with SMTP id hx2so115349000pad.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 16:51:48 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id pz7si30857313pab.1.2015.11.13.16.51.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 16:51:48 -0800 (PST)
Received: by pacej9 with SMTP id ej9so8584907pac.2
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 16:51:48 -0800 (PST)
Date: Fri, 13 Nov 2015 16:51:40 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] tmpfs: avoid a little creat and stat slowdown
In-Reply-To: <8737wafge7.fsf@yhuang-dev.intel.com>
Message-ID: <alpine.LSU.2.11.1511131645300.1539@eggly.anvils>
References: <alpine.LSU.2.11.1510291208000.3475@eggly.anvils> <87bnbagqa0.fsf@yhuang-dev.intel.com> <alpine.LSU.2.11.1511081543590.14116@eggly.anvils> <8737wafge7.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Josef Bacik <jbacik@fb.com>, Yu Zhao <yuzhao@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 13 Nov 2015, Huang, Ying wrote:
> 
> c435a390574d is the direct parent of afa2db2fb6f1 in its original git.
> 43819159da2b is your patch applied on top of v4.3-rc7.  The comparison
> of 43819159da2b with v4.3-rc7 is as follow:
...
> So you patch improved 11.9% from its base v4.3-rc7.  I think other
> difference are caused by other changes.  Sorry for confusing.

Thanks for getting back on this: that's rather what I was hoping to hear.

Of course, no user will care which commit is responsible for a slowdown,
and we may need to look further; but I couldn't make sense of it before,
so this was a relief.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
