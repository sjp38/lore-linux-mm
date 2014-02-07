Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED6D6B0037
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 15:56:18 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so3689143pad.28
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 12:56:18 -0800 (PST)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id ui8si6327549pac.206.2014.02.07.12.56.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 12:56:17 -0800 (PST)
Received: by mail-pd0-f175.google.com with SMTP id w10so3636679pde.20
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 12:56:12 -0800 (PST)
Date: Fri, 7 Feb 2014 12:56:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 7/9] mm: Mark functions as static in page_cgroup.c
In-Reply-To: <6054d570fc83c3d4f3de240d6da488f876e21450.1391167128.git.rashika.kheria@gmail.com>
Message-ID: <alpine.DEB.2.02.1402071255590.4212@chino.kir.corp.google.com>
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com> <6054d570fc83c3d4f3de240d6da488f876e21450.1391167128.git.rashika.kheria@gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-2145918811-1391806572=:4212"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rashika Kheria <rashika.kheria@gmail.com>
Cc: linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org, josh@joshtriplett.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-2145918811-1391806572=:4212
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Fri, 7 Feb 2014, Rashika Kheria wrote:

> Mark functions as static in page_cgroup.c because they are not used
> outside this file.
> 
> This eliminates the following warning in mm/page_cgroup.c:
> mm/page_cgroup.c:177:6: warning: no previous prototype for a??__free_page_cgroupa?? [-Wmissing-prototypes]
> mm/page_cgroup.c:190:15: warning: no previous prototype for a??online_page_cgroupa?? [-Wmissing-prototypes]
> mm/page_cgroup.c:225:15: warning: no previous prototype for a??offline_page_cgroupa?? [-Wmissing-prototypes]
> 
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
> Reviewed-by: Josh Triplett <josh@joshtriplett.org>

Acked-by: David Rientjes <rientjes@google.com>
--531381512-2145918811-1391806572=:4212--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
