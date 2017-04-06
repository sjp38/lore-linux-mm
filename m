Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D44BE6B0403
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 05:01:38 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id s134so6537333lfe.8
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 02:01:38 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id m25si628701lfj.343.2017.04.06.02.01.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 02:01:37 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id n78so3092691lfi.3
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 02:01:37 -0700 (PDT)
Date: Thu, 6 Apr 2017 12:01:34 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 4/4] mm: memcontrol: use node page state naming scheme
 for memcg
Message-ID: <20170406090134.GD2268@esperanza>
References: <20170404220148.28338-1-hannes@cmpxchg.org>
 <20170404220148.28338-4-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170404220148.28338-4-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Apr 04, 2017 at 06:01:48PM -0400, Johannes Weiner wrote:
> The memory controllers stat function names are awkwardly long and
> arbitrarily different from the zone and node stat functions.
> 
> The current interface is named:
> 
>   mem_cgroup_read_stat()
>   mem_cgroup_update_stat()
>   mem_cgroup_inc_stat()
>   mem_cgroup_dec_stat()
>   mem_cgroup_update_page_stat()
>   mem_cgroup_inc_page_stat()
>   mem_cgroup_dec_page_stat()
> 
> This patch renames it to match the corresponding node stat functions:
> 
>   memcg_page_state()		[node_page_state()]
>   mod_memcg_state()		[mod_node_state()]
>   inc_memcg_state()		[inc_node_state()]
>   dec_memcg_state()		[dec_node_state()]
>   mod_memcg_page_state()	[mod_node_page_state()]
>   inc_memcg_page_state()	[inc_node_page_state()]
>   dec_memcg_page_state()	[dec_node_page_state()]
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Looks neat.

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
