Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1FA616B0255
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 09:43:39 -0400 (EDT)
Received: by ykax124 with SMTP id x124so2214662yka.0
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 06:43:38 -0700 (PDT)
Received: from mail-yk0-x233.google.com (mail-yk0-x233.google.com. [2607:f8b0:4002:c07::233])
        by mx.google.com with ESMTPS id q8si9381800ykd.127.2015.08.31.06.43.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 06:43:38 -0700 (PDT)
Received: by ykap84 with SMTP id p84so2072149yka.3
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 06:43:38 -0700 (PDT)
Date: Mon, 31 Aug 2015 09:43:35 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150831134335.GB2271@mtj.duckdns.org>
References: <cover.1440960578.git.vdavydov@parallels.com>
 <20150831132414.GG29723@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150831132414.GG29723@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Mon, Aug 31, 2015 at 03:24:15PM +0200, Michal Hocko wrote:
> Right but isn't that what the caller explicitly asked for? Why should we
> ignore that for kmem accounting? It seems like a fix at a wrong layer to
> me. Either we should start failing GFP_NOWAIT charges when we are above
> high wmark or deploy an additional catchup mechanism as suggested by
> Tejun. I like the later more because it allows to better handle GFP_NOFS
> requests as well and there are many sources of these from kmem paths.

Yeah, this is beginning to look like we're trying to solve the problem
at the wrong layer.  slab/slub or whatever else should be able to use
GFP_NOWAIT in whatever frequency they want for speculative
allocations.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
