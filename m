Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 20BD46B0033
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 11:22:48 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id ez4so1913029wjd.2
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 08:22:48 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id c1si15224125wra.308.2017.01.14.08.22.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jan 2017 08:22:46 -0800 (PST)
Date: Sat, 14 Jan 2017 11:22:38 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch v2] mm, memcg: do not retry precharge charges
Message-ID: <20170114162238.GD26139@cmpxchg.org>
References: <alpine.DEB.2.10.1701112031250.94269@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1701121446130.12738@chino.kir.corp.google.com>
 <20170113084014.GB25212@dhcp22.suse.cz>
 <alpine.DEB.2.10.1701130208510.69402@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1701130208510.69402@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 13, 2017 at 02:09:53AM -0800, David Rientjes wrote:
> When memory.move_charge_at_immigrate is enabled and precharges are
> depleted during move, mem_cgroup_move_charge_pte_range() will attempt to
> increase the size of the precharge.
> 
> Prevent precharges from ever looping by setting __GFP_NORETRY.  This was
> probably the intention of the GFP_KERNEL & ~__GFP_NORETRY, which is
> pointless as written.

The OOM killer livelock was the motivation for this patch. With that
ruled out, what's the point of this patch? Try a bit less hard to move
charges during task migration?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
