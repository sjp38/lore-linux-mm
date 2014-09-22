Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 337226B0038
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 16:08:34 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id n12so1598774wgh.23
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 13:08:33 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id lg8si12368006wjb.33.2014.09.22.13.08.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 13:08:32 -0700 (PDT)
Date: Mon, 22 Sep 2014 16:08:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] memcg: move memcg_{alloc,free}_cache_params to
 slab_common.c
Message-ID: <20140922200825.GA5373@cmpxchg.org>
References: <e768785511927d65bd3e6d9f65ab2a9851a3d73d.1411054735.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e768785511927d65bd3e6d9f65ab2a9851a3d73d.1411054735.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>

On Thu, Sep 18, 2014 at 07:50:19PM +0400, Vladimir Davydov wrote:
> The only reason why they live in memcontrol.c is that we get/put css
> reference to the owner memory cgroup in them. However, we can do that in
> memcg_{un,}register_cache.
> 
> So let's move them to slab_common.c and make them static.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Christoph Lameter <cl@linux.com>

Cool, so you get rid of the back-and-forth between memcg and slab, and
thereby also shrink the public memcg interface.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
