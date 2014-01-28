Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id D99C16B0038
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 16:45:30 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id w8so1312767qac.8
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 13:45:30 -0800 (PST)
Received: from mail-qa0-x22a.google.com (mail-qa0-x22a.google.com [2607:f8b0:400d:c00::22a])
        by mx.google.com with ESMTPS id x4si12353265qad.140.2014.01.28.13.45.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 13:45:28 -0800 (PST)
Received: by mail-qa0-f42.google.com with SMTP id k4so1364799qaq.1
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 13:45:28 -0800 (PST)
Date: Tue, 28 Jan 2014 16:45:24 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Please revert 4fd466eb46a6 ("HWPOISON: add memory cgroup filter")
Message-ID: <20140128214524.GA16060@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Li Zefan <lizefan@huawei.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Andi, Wu.

Can you guys please revert 4fd466eb46a6 ("HWPOISON: add memory cgroup
filter"), which reaches into cgroup to extract the inode number and
uses that for filtering?  Nobody outside cgroup proper should be
reaching into that.  In fact, the hard association between vfs objects
and cgroup objects are going away in the upcoming devel cycle.  If you
want to tag on memcg for filtering, please introduce a proper memcg
knob.

Thank you.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
