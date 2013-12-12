Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 61CAE6B0031
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 07:11:43 -0500 (EST)
Received: by mail-ee0-f43.google.com with SMTP id c13so180799eek.16
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 04:11:42 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id m44si23380256eeo.142.2013.12.12.04.11.42
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 04:11:42 -0800 (PST)
Date: Thu, 12 Dec 2013 13:11:40 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
Message-ID: <20131212121140.GD2630@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1312031544530.5946@chino.kir.corp.google.com>
 <20131204111318.GE8410@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312041606260.6329@chino.kir.corp.google.com>
 <20131209124840.GC3597@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312091328550.11026@chino.kir.corp.google.com>
 <20131210103827.GB20242@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312101655430.22701@chino.kir.corp.google.com>
 <20131211095549.GA18741@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312111434200.7354@chino.kir.corp.google.com>
 <20131212103159.GB2630@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131212103159.GB2630@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Thu 12-12-13 11:31:59, Michal Hocko wrote:
[...]
> The semantic would be as simple as "notification is sent only when
> an action is due". It will be still racy as nothing prevents a task
> which is not under OOM to exit and release some memory but there is no
> sensible way to address that. On the other hand such a semantic would be
> sensible for oom_control listeners because they will know that an action
> has to be or will be taken (the line was drawn).
> 
> Can we agree on this, Johannes? Or you see the line drawn when
> mem_cgroup_oom_synchronize has been reached already no matter whether
> the action is to be done or not?

Something like the following:
