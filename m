Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id DC1CF6B0062
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 18:46:10 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so9883265pad.14
        for <linux-mm@kvack.org>; Thu, 18 Oct 2012 15:46:10 -0700 (PDT)
Date: Thu, 18 Oct 2012 15:46:06 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/6] cgroups: forbid pre_destroy callback to fail
Message-ID: <20121018224606.GS13370@google.com>
References: <1350480648-10905-1-git-send-email-mhocko@suse.cz>
 <1350480648-10905-5-git-send-email-mhocko@suse.cz>
 <20121018224148.GR13370@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121018224148.GR13370@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

On Thu, Oct 18, 2012 at 03:41:48PM -0700, Tejun Heo wrote:
> Note that the patch is broken in a couple places but it does show the
> general direction.  I'd prefer if patch #3 simply makes pre_destroy()
> return 0 and drop __DEPRECATED_clear_css_refs from mem_cgroup_subsys.
> Then, I can pull the branch in and drop all the unnecessary cruft.

But you need the locking change for further memcg cleanup.  To avoid
interlocked pulls from both sides, I think it's okay to push this one
with the rest of memcg changes.  I can do the cleanup on top of this
whole series, but please do drop .__DEPRECATED_clear_css_refs from
memcg.

 Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
