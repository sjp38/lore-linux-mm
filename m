Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id 00D366B0254
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 18:06:41 -0400 (EDT)
Received: by ykek5 with SMTP id k5so15379957yke.3
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 15:06:40 -0700 (PDT)
Received: from mail-yk0-x232.google.com (mail-yk0-x232.google.com. [2607:f8b0:4002:c07::232])
        by mx.google.com with ESMTPS id k68si4951259ywg.213.2015.08.28.15.06.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 15:06:40 -0700 (PDT)
Received: by ykdz80 with SMTP id z80so29232887ykd.0
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 15:06:40 -0700 (PDT)
Date: Fri, 28 Aug 2015 18:06:32 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/4] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150828220632.GF11089@htj.dyndns.org>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-4-git-send-email-tj@kernel.org>
 <20150828163611.GI9610@esperanza>
 <20150828164819.GL26785@mtj.duckdns.org>
 <20150828203231.GL9610@esperanza>
 <20150828204432.GA11089@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150828204432.GA11089@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, hannes@cmpxchg.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>

On Fri, Aug 28, 2015 at 04:44:32PM -0400, Tejun Heo wrote:
> Ah, cool, so it was a bug from slub.  Punting to return path still has
> some niceties but if we can't consistently get rid of stack
> consumption it's not that attractive.  Let's revisit it later together
> with hard limit reclaim.

So, I can't check right now but I'm pretty sure I was using SLAB on my
test config, so this issue may exist there too.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
