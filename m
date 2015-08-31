Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id B21126B0256
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 11:24:54 -0400 (EDT)
Received: by labnh1 with SMTP id nh1so48516893lab.3
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 08:24:54 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id nq2si13407409lbc.42.2015.08.31.08.24.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 08:24:53 -0700 (PDT)
Date: Mon, 31 Aug 2015 18:24:36 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150831152436.GA15420@esperanza>
References: <cover.1440960578.git.vdavydov@parallels.com>
 <20150831132414.GG29723@dhcp22.suse.cz>
 <20150831142049.GV9610@esperanza>
 <20150831144604.GD2271@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150831144604.GD2271@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 31, 2015 at 10:46:04AM -0400, Tejun Heo wrote:
> Hello, Vladimir.
> 
> On Mon, Aug 31, 2015 at 05:20:49PM +0300, Vladimir Davydov wrote:
> ...
> > That being said, this is the fix at the right layer.
> 
> While this *might* be a necessary workaround for the hard limit case
> right now, this is by no means the fix at the right layer.  The
> expectation is that mm keeps a reasonable amount of memory available
> for allocations which can't block.  These allocations may fail from
> time to time depending on luck and under extreme memory pressure but
> the caller should be able to depend on it as a speculative allocation
> mechanism which doesn't fail willy-nilly.
> 
> Hardlimit breaking GFP_NOWAIT behavior is a bug on memcg side, not
> slab or slub.

I never denied that there is GFP_NOWAIT/GFP_NOFS problem in memcg. I
even proposed ways to cope with it in one of the previous e-mails.

Nevertheless, we just can't allow slab/slub internals call memcg_charge
whenever they want as I pointed out in a parallel thread.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
