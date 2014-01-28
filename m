Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id E99836B0038
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 16:56:37 -0500 (EST)
Received: by mail-qc0-f177.google.com with SMTP id i8so1506038qcq.8
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 13:56:37 -0800 (PST)
Received: from mail-qc0-x236.google.com (mail-qc0-x236.google.com [2607:f8b0:400d:c01::236])
        by mx.google.com with ESMTPS id r5si38148qga.39.2014.01.28.13.56.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 13:56:36 -0800 (PST)
Received: by mail-qc0-f182.google.com with SMTP id c9so1552775qcz.13
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 13:56:36 -0800 (PST)
Date: Tue, 28 Jan 2014 16:56:32 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: Please revert 4fd466eb46a6 ("HWPOISON: add memory cgroup filter")
Message-ID: <20140128215632.GB16060@mtj.dyndns.org>
References: <20140128214524.GA16060@mtj.dyndns.org>
 <20140128215317.GC11821@two.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140128215317.GC11821@two.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Li Zefan <lizefan@huawei.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gong.chen@linux.intel.com

On Tue, Jan 28, 2014 at 10:53:17PM +0100, Andi Kleen wrote:
> On Tue, Jan 28, 2014 at 04:45:24PM -0500, Tejun Heo wrote:
> > Hello, Andi, Wu.
> > 
> > Can you guys please revert 4fd466eb46a6 ("HWPOISON: add memory cgroup
> > filter"), which reaches into cgroup to extract the inode number and
> > uses that for filtering?  Nobody outside cgroup proper should be
> 
> Our test suite relies on it.

Hmmm?  Ooh, I thought this just went in during this -rc1 window.  This
was way back in 2009.  I suppose cgroup should expose an interface to
query inode then.  inos changing across remounts should be okay,
right?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
