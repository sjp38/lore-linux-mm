Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 15C2082F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 11:16:14 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so91511163pab.0
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 08:16:13 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id jw6si11064267pbc.214.2015.11.05.08.16.12
        for <linux-mm@kvack.org>;
        Thu, 05 Nov 2015 08:16:13 -0800 (PST)
Date: Thu, 05 Nov 2015 11:16:09 -0500 (EST)
Message-Id: <20151105.111609.1695015438589063316.davem@davemloft.net>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
From: David Miller <davem@davemloft.net>
In-Reply-To: <20151105144002.GB15111@dhcp22.suse.cz>
References: <20151104104239.GG29607@dhcp22.suse.cz>
	<20151104195037.GA6872@cmpxchg.org>
	<20151105144002.GB15111@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

From: Michal Hocko <mhocko@kernel.org>
Date: Thu, 5 Nov 2015 15:40:02 +0100

> On Wed 04-11-15 14:50:37, Johannes Weiner wrote:
> [...]
>> Because it goes without saying that once the cgroupv2 interface is
>> released, and people use it in production, there is no way we can then
>> *add* dentry cache, inode cache, and others to memory.current. That
>> would be an unacceptable change in interface behavior.
> 
> They would still have to _enable_ the config option _explicitly_. make
> oldconfig wouldn't change it silently for them. I do not think
> it is an unacceptable change of behavior if the config is changed
> explicitly.

Every user is going to get this config option when they update their
distibution kernel or whatever.

Then they will all wonder why their networking performance went down.

This is why I do not want the networking accounting bits on by default
even if the kconfig option is enabled.  They must be off by default
and guarded by a static branch so the cost is exactly zero.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
