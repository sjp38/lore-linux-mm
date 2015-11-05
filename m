Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2219E82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 11:28:06 -0500 (EST)
Received: by wmww144 with SMTP id w144so11299412wmw.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 08:28:05 -0800 (PST)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id e16si8909079wjz.164.2015.11.05.08.28.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 08:28:05 -0800 (PST)
Received: by wikq8 with SMTP id q8so14045104wik.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 08:28:04 -0800 (PST)
Date: Thu, 5 Nov 2015 17:28:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Message-ID: <20151105162803.GD15111@dhcp22.suse.cz>
References: <20151104104239.GG29607@dhcp22.suse.cz>
 <20151104195037.GA6872@cmpxchg.org>
 <20151105144002.GB15111@dhcp22.suse.cz>
 <20151105.111609.1695015438589063316.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151105.111609.1695015438589063316.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 05-11-15 11:16:09, David S. Miller wrote:
> From: Michal Hocko <mhocko@kernel.org>
> Date: Thu, 5 Nov 2015 15:40:02 +0100
> 
> > On Wed 04-11-15 14:50:37, Johannes Weiner wrote:
> > [...]
> >> Because it goes without saying that once the cgroupv2 interface is
> >> released, and people use it in production, there is no way we can then
> >> *add* dentry cache, inode cache, and others to memory.current. That
> >> would be an unacceptable change in interface behavior.
> > 
> > They would still have to _enable_ the config option _explicitly_. make
> > oldconfig wouldn't change it silently for them. I do not think
> > it is an unacceptable change of behavior if the config is changed
> > explicitly.
> 
> Every user is going to get this config option when they update their
> distibution kernel or whatever.
> 
> Then they will all wonder why their networking performance went down.
> 
> This is why I do not want the networking accounting bits on by default
> even if the kconfig option is enabled.  They must be off by default
> and guarded by a static branch so the cost is exactly zero.

Yes, that part is clear and Johannes made it clear that the kmem tcp
part is disabled by default. Or are you considering also all the slab
usage by the networking code as well?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
