Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 65AD26B0038
	for <linux-mm@kvack.org>; Sat, 29 Aug 2015 03:59:24 -0400 (EDT)
Received: by pabzx8 with SMTP id zx8so85650203pab.1
        for <linux-mm@kvack.org>; Sat, 29 Aug 2015 00:59:24 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id lw2si14104628pdb.44.2015.08.29.00.59.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Aug 2015 00:59:23 -0700 (PDT)
Date: Sat, 29 Aug 2015 10:59:05 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 3/4] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150829075905.GO9610@esperanza>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-4-git-send-email-tj@kernel.org>
 <20150828163611.GI9610@esperanza>
 <20150828164819.GL26785@mtj.duckdns.org>
 <20150828203231.GL9610@esperanza>
 <20150828204432.GA11089@htj.dyndns.org>
 <20150828220632.GF11089@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150828220632.GF11089@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, hannes@cmpxchg.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>

On Fri, Aug 28, 2015 at 06:06:32PM -0400, Tejun Heo wrote:
> On Fri, Aug 28, 2015 at 04:44:32PM -0400, Tejun Heo wrote:
> > Ah, cool, so it was a bug from slub.  Punting to return path still has
> > some niceties but if we can't consistently get rid of stack
> > consumption it's not that attractive.  Let's revisit it later together
> > with hard limit reclaim.
> 
> So, I can't check right now but I'm pretty sure I was using SLAB on my
> test config, so this issue may exist there too.

Yeah, SLAB is broken too. It was accidentally broken by commit
4167e9b2cf10 ("mm: remove GFP_THISNODE"), which among other things made
SLAB filter out __GFP_WAIT from gfp flags when probing a NUMA node. I'll
take a look what we can do with that.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
