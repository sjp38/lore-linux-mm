Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB856B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 02:35:45 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id v77so6301138wmv.5
        for <linux-mm@kvack.org>; Sun, 15 Jan 2017 23:35:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h6si515300wrb.227.2017.01.15.23.35.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 15 Jan 2017 23:35:44 -0800 (PST)
Date: Mon, 16 Jan 2017 08:35:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, memcg: do not retry precharge charges
Message-ID: <20170116073540.GB7981@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1701112031250.94269@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1701121446130.12738@chino.kir.corp.google.com>
 <20170113084014.GB25212@dhcp22.suse.cz>
 <alpine.DEB.2.10.1701130208510.69402@chino.kir.corp.google.com>
 <20170114162238.GD26139@cmpxchg.org>
 <alpine.DEB.2.10.1701142137020.8668@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1701142137020.8668@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat 14-01-17 21:42:48, David Rientjes wrote:
> On Sat, 14 Jan 2017, Johannes Weiner wrote:
> 
> > The OOM killer livelock was the motivation for this patch. With that
> > ruled out, what's the point of this patch? Try a bit less hard to move
> > charges during task migration?
> > 
> 
> Most important part is to fail ->can_attach() instead of oom killing 
> processes when attaching a process to a memcg hierarchy.

But we are not invoking the oom killer from this path even without
__GFP_NORETRY. Or am I missing your point?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
