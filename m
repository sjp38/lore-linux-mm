Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 975316B0253
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 10:54:54 -0500 (EST)
Received: by ykfs79 with SMTP id s79so55246180ykf.1
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 07:54:54 -0800 (PST)
Received: from mail-yk0-x229.google.com (mail-yk0-x229.google.com. [2607:f8b0:4002:c07::229])
        by mx.google.com with ESMTPS id w7si6491960ywb.361.2015.11.11.07.54.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 07:54:53 -0800 (PST)
Received: by ykfs79 with SMTP id s79so55245421ykf.1
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 07:54:53 -0800 (PST)
Date: Wed, 11 Nov 2015 10:54:50 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 4/6] slab: add SLAB_ACCOUNT flag
Message-ID: <20151111155450.GB6246@mtj.duckdns.org>
References: <cover.1447172835.git.vdavydov@virtuozzo.com>
 <1ce23e932ea53f47a3376de90b21a9db8293bd6c.1447172835.git.vdavydov@virtuozzo.com>
 <20151110183808.GB13740@mtj.duckdns.org>
 <20151110185401.GW31308@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151110185401.GW31308@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Tue, Nov 10, 2015 at 09:54:01PM +0300, Vladimir Davydov wrote:
> > Am I correct in thinking that we should eventually be able to removed
> > __GFP_ACCOUNT and that only caches explicitly marked with SLAB_ACCOUNT
> > would need to be handled by kmemcg?
> 
> Don't think so, because sometimes we want to account kmalloc.

I'm kinda skeptical about that because if those allocations are
occassional by nature, we don't care and if there can be a huge number
of them, splitting them into a separate cache makes sense.  I think it
makes sense to pin down exactly which caches are memcg managed.  That
has the potential to simplify the involved code path and shave off a
small bit of hot path overhead.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
