Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4BEB26B0253
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 12:11:11 -0400 (EDT)
Received: by pacws9 with SMTP id ws9so135527939pac.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 09:11:11 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ns4si4777325pdb.246.2015.07.08.09.11.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 09:11:10 -0700 (PDT)
Date: Wed, 8 Jul 2015 19:11:01 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 6/8] memcg, tcp_kmem: check for cg_proto in
 sock_update_memcg
Message-ID: <20150708161101.GF2436@esperanza>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
 <1436358472-29137-7-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1436358472-29137-7-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

On Wed, Jul 08, 2015 at 02:27:50PM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.cz>
> 
> sk_prot->proto_cgroup is allowed to return NULL but sock_update_memcg
> doesn't check for NULL. The function relies on the mem_cgroup_is_root
> check because we shouldn't get NULL otherwise because
> mem_cgroup_from_task will always return !NULL.
> 
> All other callers are checking for NULL and we can safely replace
> mem_cgroup_is_root() check by cg_proto != NULL which will be more
> straightforward (proto_cgroup returns NULL for the root memcg already).
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
