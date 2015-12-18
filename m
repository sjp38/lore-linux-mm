Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id D34596B0005
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 11:42:22 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l126so72998094wml.1
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 08:42:22 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id om6si26797113wjc.34.2015.12.18.08.42.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Dec 2015 08:42:21 -0800 (PST)
Date: Fri, 18 Dec 2015 11:42:09 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: fix SLOB build regression
Message-ID: <20151218164209.GD4201@cmpxchg.org>
References: <13705081.IYJlPWfILN@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <13705081.IYJlPWfILN@wuerfel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

On Fri, Dec 18, 2015 at 03:35:06PM +0100, Arnd Bergmann wrote:
> A recent cleanup broke the build when CONFIG_SLOB is used:
> 
> mm/memcontrol.c: In function 'memcg_update_kmem_limit':
> mm/memcontrol.c:2974:9: error: implicit declaration of function 'memcg_online_kmem' [-Werror=implicit-function-declaration]
> mm/memcontrol.c: In function 'mem_cgroup_css_alloc':
> mm/memcontrol.c:4229:10: error: too many arguments to function 'memcg_propagate_kmem'
> mm/memcontrol.c:2949:12: note: declared here
> 
> This fixes the memcg_propagate_kmem prototype to match the normal
> implementation and adds the respective memcg_online_kmem helper
> function that was needed.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: a5ed904c5039 ("mm: memcontrol: clean up alloc, online, offline, free functions")

I am slob.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
