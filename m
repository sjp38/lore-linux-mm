Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 337856B0037
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 16:43:26 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id q5so449498wiv.16
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 13:43:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cx3si5825792wib.94.2014.03.27.13.43.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 27 Mar 2014 13:43:24 -0700 (PDT)
Date: Thu, 27 Mar 2014 13:43:20 -0700
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm 1/4] sl[au]b: do not charge large allocations to memcg
Message-ID: <20140327204320.GC28590@dhcp22.suse.cz>
References: <cover.1395846845.git.vdavydov@parallels.com>
 <5a5b09d4cb9a15fc120b4bec8be168630a3b43c2.1395846845.git.vdavydov@parallels.com>
 <xr93fvm42rew.fsf@gthelen.mtv.corp.google.com>
 <5333D527.2060208@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5333D527.2060208@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Greg Thelen <gthelen@google.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

On Thu 27-03-14 11:37:11, Vladimir Davydov wrote:
[...]
> In fact, do we actually need to charge every random kmem allocation? I
> guess not. For instance, filesystems often allocate data shared among
> all the FS users. It's wrong to charge such allocations to a particular
> memcg, IMO. That said the next step is going to be adding a per kmem
> cache flag specifying if allocations from this cache should be charged
> so that accounting will work only for those caches that are marked so
> explicitly.

How do you select which caches to track?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
