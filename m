Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5F14C828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 19:43:53 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id e65so90079343pfe.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 16:43:53 -0800 (PST)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id dx9si5357962pab.202.2016.01.13.16.43.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 16:43:52 -0800 (PST)
Received: by mail-pf0-x22b.google.com with SMTP id 65so89824439pff.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 16:43:52 -0800 (PST)
Date: Wed, 13 Jan 2016 16:43:51 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 3/3] oom: Do not try to sacrifice small children
In-Reply-To: <20160113094034.GC28942@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1601131642560.3406@chino.kir.corp.google.com>
References: <1452632425-20191-1-git-send-email-mhocko@kernel.org> <1452632425-20191-4-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1601121646410.28831@chino.kir.corp.google.com> <20160113094034.GC28942@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Wed, 13 Jan 2016, Michal Hocko wrote:

> > The purpose of sacrificing a child has always been to prevent a process 
> > that has been running with a substantial amount of work done from being 
> > terminated and losing all that work if it can be avoided.  This happens a 
> > lot: imagine a long-living front end client forking a child which simply 
> > collects stats and malloc information at a regular intervals and writes 
> > them out to disk or over the network.  These processes may be quite small, 
> > and we're willing to happily sacrifice them if it will save the parent.  
> > This was, and still is, the intent of the sacrifice in the first place.
> 
> Yes I understand the intention of the heuristic. I am just contemplating
> about what is way too small to sacrifice because it clearly doesn't make
> much sense to kill a task which is sitting on basically no memory (well
> just few pages backing page tables and stack) because this would just
> prolong the OOM agony.
> 

Nothing is ever too small to kill since we allow userspace the ability to 
define their own oom priority.  We would rather kill your bash shell when 
you login rather than your sshd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
