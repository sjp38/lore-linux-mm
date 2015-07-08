Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 485EF6B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 11:41:22 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so133683195pac.2
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 08:41:22 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id b7si4650709pat.208.2015.07.08.08.41.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 08:41:21 -0700 (PDT)
Date: Wed, 8 Jul 2015 18:41:12 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 2/8] memcg: get rid of mem_cgroup_root_css for
 !CONFIG_MEMCG
Message-ID: <20150708154111.GB2436@esperanza>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
 <1436358472-29137-3-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1436358472-29137-3-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 08, 2015 at 02:27:46PM +0200, Michal Hocko wrote:
> The only user is cgwb_bdi_init and that one depends on
> CONFIG_CGROUP_WRITEBACK which in turn depends on CONFIG_MEMCG
> so it doesn't make much sense to definte an empty stub for
> !CONFIG_MEMCG. Moreover ERR_PTR(-EINVAL) is ugly and would lead
> to runtime crashes if used in unguarded code paths. Better fail
> during compilation.
> 
> Signed-off-by: Michal Hocko <mhocko@kernel.org>

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
