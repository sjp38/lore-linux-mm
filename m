Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id DAC806B0036
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 15:55:25 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so3694190pab.33
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 12:55:25 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id d4si6323295pao.215.2014.02.07.12.55.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 12:55:24 -0800 (PST)
Received: by mail-pa0-f42.google.com with SMTP id kl14so3680042pab.15
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 12:55:24 -0800 (PST)
Date: Fri, 7 Feb 2014 12:55:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 6/9] mm: Mark function as static in memcontrol.c
In-Reply-To: <0dbbc0fe4360069993ef8a9ca179f30482610270.1391167128.git.rashika.kheria@gmail.com>
Message-ID: <alpine.DEB.2.02.1402071254410.4212@chino.kir.corp.google.com>
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com> <0dbbc0fe4360069993ef8a9ca179f30482610270.1391167128.git.rashika.kheria@gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-204402537-1391806523=:4212"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rashika Kheria <rashika.kheria@gmail.com>
Cc: linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, josh@joshtriplett.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-204402537-1391806523=:4212
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Fri, 7 Feb 2014, Rashika Kheria wrote:

> Mark function as static in memcontrol.c because it is not used outside
> this file.
> 
> This also eliminates the following warning in memcontrol.c:
> mm/memcontrol.c:3089:5: warning: no previous prototype for a??memcg_update_cache_sizesa?? [-Wmissing-prototypes]
> 
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
> Reviewed-by: Josh Triplett <josh@joshtriplett.org>

memcg_update_cache_sizes() was removed in commit d6441637709b ("memcg: 
rework memcg_update_kmem_limit synchronization") for 3.14-rc1.
--531381512-204402537-1391806523=:4212--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
