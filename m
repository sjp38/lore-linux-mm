Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id C1F426B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:05:06 -0500 (EST)
Received: by wmvv187 with SMTP id v187so40697069wmv.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 11:05:06 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 73si49897265wma.35.2015.11.19.11.05.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 11:05:05 -0800 (PST)
Date: Thu, 19 Nov 2015 14:04:55 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 5/6] vmalloc: allow to account vmalloc to memcg
Message-ID: <20151119190455.GE3941@cmpxchg.org>
References: <cover.1447172835.git.vdavydov@virtuozzo.com>
 <b02165792beff56fa6a13bc23b9a21df11395aec.1447172835.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b02165792beff56fa6a13bc23b9a21df11395aec.1447172835.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Nov 10, 2015 at 09:34:06PM +0300, Vladimir Davydov wrote:
> This patch makes vmalloc family functions allocate vmalloc area pages
> with alloc_kmem_pages so that if __GFP_ACCOUNT is set they will be
> accounted to memcg. This is needed, at least, to account alloc_fdmem
> allocations.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
