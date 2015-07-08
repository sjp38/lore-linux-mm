Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 43F6C6B0253
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 12:05:56 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so133895013pab.1
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 09:05:56 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id wm10si4819298pbc.54.2015.07.08.09.05.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 09:05:55 -0700 (PDT)
Date: Wed, 8 Jul 2015 19:05:44 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 5/8] memcg: restructure mem_cgroup_can_attach()
Message-ID: <20150708160544.GE2436@esperanza>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
 <1436358472-29137-6-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1436358472-29137-6-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 08, 2015 at 02:27:49PM +0200, Michal Hocko wrote:
> From: Tejun Heo <tj@kernel.org>
> 
> Restructure it to lower nesting level and help the planned threadgroup
> leader iteration changes.
> 
> This is pure reorganization.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Michal Hocko <mhocko@suse.cz>

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
