Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id B187982F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 12:45:47 -0500 (EST)
Received: by wmec201 with SMTP id c201so24444107wme.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 09:45:47 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p10si1577759wjo.3.2015.11.06.09.45.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2015 09:45:46 -0800 (PST)
Date: Fri, 6 Nov 2015 12:45:17 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Message-ID: <20151106174517.GA9315@cmpxchg.org>
References: <20151029152546.GG23598@dhcp22.suse.cz>
 <20151029161009.GA9160@cmpxchg.org>
 <20151104104239.GG29607@dhcp22.suse.cz>
 <20151104195037.GA6872@cmpxchg.org>
 <20151105144002.GB15111@dhcp22.suse.cz>
 <20151105205522.GA1067@cmpxchg.org>
 <20151105225200.GA5432@cmpxchg.org>
 <20151106105724.GG4390@dhcp22.suse.cz>
 <20151106161953.GA7813@cmpxchg.org>
 <20151106164657.GL4390@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151106164657.GL4390@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Nov 06, 2015 at 05:46:57PM +0100, Michal Hocko wrote:
> The basic problem was that the Delegate feature has been backported to
> our systemd package without further consideration and that has
> invalidated a lot of performance testing because some resource
> controllers have measurable effects on those benchmarks.

You're talking about a userspace bug. No amount of fragmenting and
layering and opt-in in the kernel's runtime configuration space is
going to help you if you screw up and enable it all by accident.

> > All I read here is vague inflammatory language to spread FUD.
> 
> I was merely pointing out that memory controller might be enabled without
> _user_ actually even noticing because the controller wasn't enabled
> explicitly. I haven't blamed anybody for that.

Why does that have anything to do with how we design our interface?

We can't do more than present a sane interface in good faith and lobby
userspace projects if we think they misuse it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
