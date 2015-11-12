Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8CD6B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 14:12:37 -0500 (EST)
Received: by wmww144 with SMTP id w144so531992wmw.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 11:12:37 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ci5si20261785wjc.170.2015.11.12.11.12.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 11:12:36 -0800 (PST)
Date: Thu, 12 Nov 2015 14:12:20 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Message-ID: <20151112191220.GA25750@cmpxchg.org>
References: <20151029152546.GG23598@dhcp22.suse.cz>
 <20151029161009.GA9160@cmpxchg.org>
 <20151104104239.GG29607@dhcp22.suse.cz>
 <20151104195037.GA6872@cmpxchg.org>
 <20151105144002.GB15111@dhcp22.suse.cz>
 <20151105205522.GA1067@cmpxchg.org>
 <20151105225200.GA5432@cmpxchg.org>
 <20151106105724.GG4390@dhcp22.suse.cz>
 <20151106161953.GA7813@cmpxchg.org>
 <20151112183620.GC14880@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151112183620.GC14880@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>, David Miller <davem@davemloft.net>, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Nov 12, 2015 at 06:36:20PM +0000, Mel Gorman wrote:
> Bottom line, there is legimate confusion over whether cgroup controllers
> are going to be enabled by default or not in the future. If they are
> enabled by default, there is a non-zero cost to that and a change in
> semantics that people may or may not be surprised by.

Thanks for elaborating, Mel.

My understanding is that this is a plain bug. I don't think anybody
wants to put costs without benefits on their users.

But I'll keep an eye on these reports, and I'll work with the systemd
people should issues with the kernel interface materialize that would
force them to enable resource control prematurely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
