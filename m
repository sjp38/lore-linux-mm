Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6E0B76B0033
	for <linux-mm@kvack.org>; Sun, 15 Jan 2017 00:42:51 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 201so44005897pfw.5
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 21:42:51 -0800 (PST)
Received: from mail-pg0-x234.google.com (mail-pg0-x234.google.com. [2607:f8b0:400e:c05::234])
        by mx.google.com with ESMTPS id 137si17609958pfa.58.2017.01.14.21.42.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jan 2017 21:42:50 -0800 (PST)
Received: by mail-pg0-x234.google.com with SMTP id 204so6321056pge.0
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 21:42:50 -0800 (PST)
Date: Sat, 14 Jan 2017 21:42:48 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, memcg: do not retry precharge charges
In-Reply-To: <20170114162238.GD26139@cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1701142137020.8668@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1701112031250.94269@chino.kir.corp.google.com> <alpine.DEB.2.10.1701121446130.12738@chino.kir.corp.google.com> <20170113084014.GB25212@dhcp22.suse.cz> <alpine.DEB.2.10.1701130208510.69402@chino.kir.corp.google.com>
 <20170114162238.GD26139@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 14 Jan 2017, Johannes Weiner wrote:

> The OOM killer livelock was the motivation for this patch. With that
> ruled out, what's the point of this patch? Try a bit less hard to move
> charges during task migration?
> 

Most important part is to fail ->can_attach() instead of oom killing 
processes when attaching a process to a memcg hierarchy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
