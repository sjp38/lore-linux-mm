Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8DBD08309E
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 00:48:13 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id g62so100969793wme.0
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 21:48:13 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 130si12140342wmj.112.2016.02.07.21.48.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Feb 2016 21:48:12 -0800 (PST)
Date: Mon, 8 Feb 2016 00:47:58 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/5] mm: vmscan: pass root_mem_cgroup instead of NULL to
 memcg aware shrinker
Message-ID: <20160208054758.GB22202@cmpxchg.org>
References: <cover.1454864628.git.vdavydov@virtuozzo.com>
 <37826932f643b15c6eeeda4006e4e37a9f3fd8a6.1454864628.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <37826932f643b15c6eeeda4006e4e37a9f3fd8a6.1454864628.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Feb 07, 2016 at 08:27:32PM +0300, Vladimir Davydov wrote:
> It's just convenient to implement a memcg aware shrinker when you know
> that shrink_control->memcg != NULL unless memcg_kmem_enabled() returns
> false.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
