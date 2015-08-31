Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id 71D3F6B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 10:39:43 -0400 (EDT)
Received: by ykfj9 with SMTP id j9so4034416ykf.2
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 07:39:43 -0700 (PDT)
Received: from mail-yk0-x229.google.com (mail-yk0-x229.google.com. [2607:f8b0:4002:c07::229])
        by mx.google.com with ESMTPS id c9si9489801ykb.3.2015.08.31.07.39.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 07:39:42 -0700 (PDT)
Received: by ykax124 with SMTP id x124so4148000yka.0
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 07:39:42 -0700 (PDT)
Date: Mon, 31 Aug 2015 10:39:39 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150831143939.GC2271@mtj.duckdns.org>
References: <cover.1440960578.git.vdavydov@parallels.com>
 <20150831132414.GG29723@dhcp22.suse.cz>
 <20150831134335.GB2271@mtj.duckdns.org>
 <20150831143007.GA13814@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150831143007.GA13814@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 31, 2015 at 05:30:08PM +0300, Vladimir Davydov wrote:
> slab/slub can issue alloc_pages() any time with any flags they want and
> it won't be accounted to memcg, because kmem is accounted at slab/slub
> layer, not in buddy.

Hmmm?  I meant the eventual calling into try_charge w/ GFP_NOWAIT.
Speculative usage of GFP_NOWAIT is bound to increase and we don't want
to put on extra restrictions from memcg side.  For memory.high,
punting to the return path is a pretty stright-forward solution which
should make the problem go away almost entirely.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
