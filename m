Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B526F6B0033
	for <linux-mm@kvack.org>; Sun, 15 Jan 2017 10:19:26 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r144so24157643wme.0
        for <linux-mm@kvack.org>; Sun, 15 Jan 2017 07:19:26 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 34si18384050wrc.11.2017.01.15.07.19.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Jan 2017 07:19:24 -0800 (PST)
Date: Sun, 15 Jan 2017 10:19:14 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch v2] mm, memcg: do not retry precharge charges
Message-ID: <20170115151914.GA28947@cmpxchg.org>
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
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Jan 14, 2017 at 09:42:48PM -0800, David Rientjes wrote:
> On Sat, 14 Jan 2017, Johannes Weiner wrote:
> 
> > The OOM killer livelock was the motivation for this patch. With that
> > ruled out, what's the point of this patch? Try a bit less hard to move
> > charges during task migration?
> > 
> 
> Most important part is to fail ->can_attach() instead of oom killing 
> processes when attaching a process to a memcg hierarchy.

Ah, that makes sense.

Could you please update the changelog to reflect this? Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
