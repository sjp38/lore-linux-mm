Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id B39346B0035
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 13:52:20 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id md12so687422pbc.7
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 10:52:20 -0800 (PST)
Received: from psmtp.com ([74.125.245.148])
        by mx.google.com with SMTP id qj1si10357017pbc.84.2013.11.18.10.52.17
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 10:52:18 -0800 (PST)
Received: by mail-ea0-f180.google.com with SMTP id f15so879018eak.39
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 10:52:15 -0800 (PST)
Date: Mon, 18 Nov 2013 19:52:13 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/2] mm, memcg: add memory.oom_control notification for
 system oom
Message-ID: <20131118185213.GA12923@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1310301838300.13556@chino.kir.corp.google.com>
 <20131031054942.GA26301@cmpxchg.org>
 <alpine.DEB.2.02.1311131416460.23211@chino.kir.corp.google.com>
 <20131113233419.GJ707@cmpxchg.org>
 <alpine.DEB.2.02.1311131649110.6735@chino.kir.corp.google.com>
 <20131114032508.GL707@cmpxchg.org>
 <alpine.DEB.2.02.1311141447160.21413@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1311141525440.30112@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1311141526300.30112@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311141526300.30112@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Thu 14-11-13 15:26:55, David Rientjes wrote:
> A subset of applications that wait on memory.oom_control don't disable
> the oom killer for that memcg and simply log or cleanup after the kernel
> oom killer kills a process to free memory.
> 
> We need the ability to do this for system oom conditions as well, i.e.
> when the system is depleted of all memory and must kill a process.  For
> convenience, this can use memcg since oom notifiers are already present.

Using the memcg interface for "read-only" interface without any plan for
the "write" is only halfway solution. We want to handle global OOM in a
more user defined ways but we have to agree on the proper interface
first. I do not want to end up with something half baked with memcg and
a different interface to do the real thing just because memcg turns out
to be unsuitable.

And to be honest, the more I am thinking about memcg based interface the
stronger is my feeling that it is unsuitable for the user defined OOM
policies. But that should be discussed properly (I will send a RFD in
the follow up days).

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
