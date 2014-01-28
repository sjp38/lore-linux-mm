Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id EA8176B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 16:57:48 -0500 (EST)
Received: by mail-ee0-f52.google.com with SMTP id e53so499124eek.25
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 13:57:48 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id m44si80150eef.44.2014.01.28.13.57.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 13:57:48 -0800 (PST)
Date: Tue, 28 Jan 2014 22:57:47 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Please revert 4fd466eb46a6 ("HWPOISON: add memory cgroup
 filter")
Message-ID: <20140128215747.GD11821@two.firstfloor.org>
References: <20140128214524.GA16060@mtj.dyndns.org>
 <20140128215317.GC11821@two.firstfloor.org>
 <20140128215632.GB16060@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140128215632.GB16060@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andi Kleen <andi@firstfloor.org>, Li Zefan <lizefan@huawei.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gong.chen@linux.intel.com

> inos changing across remounts should be okay,
> right?

Yes that's fine.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
