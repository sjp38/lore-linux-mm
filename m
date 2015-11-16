Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 445876B0038
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 13:18:23 -0500 (EST)
Received: by lbbsy6 with SMTP id sy6so64881324lbb.2
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 10:18:22 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u8si27335021lbb.149.2015.11.16.10.18.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 10:18:21 -0800 (PST)
Date: Mon, 16 Nov 2015 13:18:10 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 13/14] mm: memcontrol: account socket memory in unified
 hierarchy memory controller
Message-ID: <20151116181810.GB32544@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-14-git-send-email-hannes@cmpxchg.org>
 <20151116155923.GH14116@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151116155923.GH14116@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Nov 16, 2015 at 04:59:25PM +0100, Michal Hocko wrote:
> On Thu 12-11-15 18:41:32, Johannes Weiner wrote:
> > Socket memory can be a significant share of overall memory consumed by
> > common workloads. In order to provide reasonable resource isolation in
> > the unified hierarchy, this type of memory needs to be included in the
> > tracking/accounting of a cgroup under active memory resource control.
> > 
> > Overhead is only incurred when a non-root control group is created AND
> > the memory controller is instructed to track and account the memory
> > footprint of that group. cgroup.memory=nosocket can be specified on
> > the boot commandline to override any runtime configuration and
> > forcibly exclude socket memory from active memory resource control.
> 
> Do you have any numbers about the overhead?

Hm? Performance numbers make sense when you have a specific scenario
and a theory on how to optimize the implementation for it. What load
would you test and what would be the baseline to compare it to?

> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> With a way to disable this feature I am OK with it.
> cgroup.memory=nosocket should be documented (at least in
> Documentation/kernel-parameters.txt)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index f8aae63..d518340 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -599,6 +599,10 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			cut the overhead, others just disable the usage. So
 			only cgroup_disable=memory is actually worthy}
 
+	cgroup.memory=	[KNL] Pass options to the cgroup memory controller.
+			Format: <string>
+			nosocket -- Disable socket memory accounting.
+
 	checkreqprot	[SELINUX] Set initial checkreqprot flag value.
 			Format: { "0" | "1" }
 			See security/selinux/Kconfig help text.

> Other than that
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

---
