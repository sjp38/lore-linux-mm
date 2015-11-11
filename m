Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id C7E956B0253
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 11:19:09 -0500 (EST)
Received: by ykfs79 with SMTP id s79so56605885ykf.1
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 08:19:09 -0800 (PST)
Received: from mail-yk0-x233.google.com (mail-yk0-x233.google.com. [2607:f8b0:4002:c07::233])
        by mx.google.com with ESMTPS id p184si6600761ywf.101.2015.11.11.08.19.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 08:19:09 -0800 (PST)
Received: by ykba77 with SMTP id a77so56262848ykb.2
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 08:19:08 -0800 (PST)
Date: Wed, 11 Nov 2015 11:19:04 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 4/6] slab: add SLAB_ACCOUNT flag
Message-ID: <20151111161904.GE6246@mtj.duckdns.org>
References: <cover.1447172835.git.vdavydov@virtuozzo.com>
 <1ce23e932ea53f47a3376de90b21a9db8293bd6c.1447172835.git.vdavydov@virtuozzo.com>
 <20151110183808.GB13740@mtj.duckdns.org>
 <20151110185401.GW31308@esperanza>
 <20151111155450.GB6246@mtj.duckdns.org>
 <20151111160719.GX31308@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151111160719.GX31308@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hello, Vladimir.

On Wed, Nov 11, 2015 at 07:07:19PM +0300, Vladimir Davydov wrote:
> What about external_name allocation in __d_alloc? Is it occasional?
> Depends on the workload I guess. Can we create a separate cache for it?
> No, because its size is variable. There are other things like that, e.g.
> pipe_buffer array.

You're right.  Ah, it was so close. :(

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
