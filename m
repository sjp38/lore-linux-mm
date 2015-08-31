Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id C1D6F6B0256
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 10:46:07 -0400 (EDT)
Received: by ykap84 with SMTP id p84so4197518yka.3
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 07:46:07 -0700 (PDT)
Received: from mail-yk0-x229.google.com (mail-yk0-x229.google.com. [2607:f8b0:4002:c07::229])
        by mx.google.com with ESMTPS id d133si9473596yka.150.2015.08.31.07.46.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 07:46:07 -0700 (PDT)
Received: by ykax124 with SMTP id x124so4364254yka.0
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 07:46:06 -0700 (PDT)
Date: Mon, 31 Aug 2015 10:46:04 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150831144604.GD2271@mtj.duckdns.org>
References: <cover.1440960578.git.vdavydov@parallels.com>
 <20150831132414.GG29723@dhcp22.suse.cz>
 <20150831142049.GV9610@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150831142049.GV9610@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Vladimir.

On Mon, Aug 31, 2015 at 05:20:49PM +0300, Vladimir Davydov wrote:
...
> That being said, this is the fix at the right layer.

While this *might* be a necessary workaround for the hard limit case
right now, this is by no means the fix at the right layer.  The
expectation is that mm keeps a reasonable amount of memory available
for allocations which can't block.  These allocations may fail from
time to time depending on luck and under extreme memory pressure but
the caller should be able to depend on it as a speculative allocation
mechanism which doesn't fail willy-nilly.

Hardlimit breaking GFP_NOWAIT behavior is a bug on memcg side, not
slab or slub.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
