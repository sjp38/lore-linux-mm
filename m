Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 841686B008A
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 16:17:41 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so754762pbb.14
        for <linux-mm@kvack.org>; Fri, 19 Oct 2012 13:17:40 -0700 (PDT)
Date: Fri, 19 Oct 2012 13:17:36 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/6] cgroups: forbid pre_destroy callback to fail
Message-ID: <20121019201736.GQ13370@google.com>
References: <1350480648-10905-1-git-send-email-mhocko@suse.cz>
 <1350480648-10905-5-git-send-email-mhocko@suse.cz>
 <50811E5E.1090205@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50811E5E.1090205@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

On Fri, Oct 19, 2012 at 05:33:18PM +0800, Li Zefan wrote:
> On 2012/10/17 21:30, Michal Hocko wrote:
> > Now that mem_cgroup_pre_destroy callback doesn't fail finally we can
> > safely move on and forbit all the callbacks to fail. The last missing
> > piece is moving cgroup_call_pre_destroy after cgroup_clear_css_refs so
> > that css_tryget fails so no new charges for the memcg can happen.
> 
> > The callbacks are also called from within cgroup_lock to guarantee that
> > no new tasks show up. 
> 
> I'm afraid this won't work. See commit 3fa59dfbc3b223f02c26593be69ce6fc9a940405
> ("cgroup: fix potential deadlock in pre_destroy")

Yeah, you're right.  Argh... we really should unexport cgroup_lock
soon.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
