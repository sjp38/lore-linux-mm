Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 00CE36B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 21:31:04 -0400 (EDT)
Received: by mail-ie0-f179.google.com with SMTP id e14so7767060iej.38
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 18:31:04 -0700 (PDT)
Received: by mail-qc0-f182.google.com with SMTP id n4so2720041qcx.27
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 18:31:02 -0700 (PDT)
Date: Mon, 23 Sep 2013 21:30:58 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v6 0/5] memcg, cgroup: kill css id
Message-ID: <20130924013058.GB3482@htj.dyndns.org>
References: <524001F8.6070205@huawei.com>
 <20130923130816.GH30946@htj.dyndns.org>
 <20130923131215.GI30946@htj.dyndns.org>
 <5240DD83.1070509@huawei.com>
 <20130923175247.ea5156de.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130923175247.ea5156de.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hello, Andrew.

On Mon, Sep 23, 2013 at 05:52:47PM -0700, Andrew Morton wrote:
> > I would love to see this patchset go through cgroup tree. The changes to
> > memcg is quite small,
> 
> It seems logical to put this in the cgroup tree as that's where most of
> the impact occurs.

Cool, applying the changes to cgroup/for-3.13.

> > and as -mm tree is based on -next it won't cause
> > future conflicts.
> 
> That's no longer the case - I'm staging -mm patches ahead of linux-next
> now.  Except in cases where that's impractical, such as the 3.12 memcg
> changes which were pretty heavily impacted by cgroups tree changes.

Please note that cgroup is likely to continue to go through a lot of
changes for the foreseeable future and memcg is likely to be affected
heavily.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
