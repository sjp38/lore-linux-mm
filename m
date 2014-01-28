Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7F6A26B0038
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 16:53:19 -0500 (EST)
Received: by mail-ee0-f43.google.com with SMTP id c41so503638eek.2
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 13:53:19 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id d41si30334200eep.239.2014.01.28.13.53.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 13:53:18 -0800 (PST)
Date: Tue, 28 Jan 2014 22:53:17 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Please revert 4fd466eb46a6 ("HWPOISON: add memory cgroup
 filter")
Message-ID: <20140128215317.GC11821@two.firstfloor.org>
References: <20140128214524.GA16060@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140128214524.GA16060@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andi Kleen <andi@firstfloor.org>, Li Zefan <lizefan@huawei.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gong.chen@linux.intel.com

On Tue, Jan 28, 2014 at 04:45:24PM -0500, Tejun Heo wrote:
> Hello, Andi, Wu.
> 
> Can you guys please revert 4fd466eb46a6 ("HWPOISON: add memory cgroup
> filter"), which reaches into cgroup to extract the inode number and
> uses that for filtering?  Nobody outside cgroup proper should be

Our test suite relies on it.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
