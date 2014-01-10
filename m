Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id D8B216B0039
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 16:38:54 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id t59so1502604yho.20
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 13:38:54 -0800 (PST)
Received: from mail-gg0-x234.google.com (mail-gg0-x234.google.com [2607:f8b0:4002:c02::234])
        by mx.google.com with ESMTPS id z48si10535705yha.6.2014.01.10.13.38.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 10 Jan 2014 13:38:54 -0800 (PST)
Received: by mail-gg0-f180.google.com with SMTP id q3so825218gge.25
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 13:38:53 -0800 (PST)
Date: Fri, 10 Jan 2014 13:38:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
In-Reply-To: <20140110083025.GE9437@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1401101335200.21486@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1312131551220.28704@chino.kir.corp.google.com> <20131217162342.GG28991@dhcp22.suse.cz> <alpine.DEB.2.02.1312171240541.21640@chino.kir.corp.google.com> <20131218200434.GA4161@dhcp22.suse.cz> <alpine.DEB.2.02.1312182157510.1247@chino.kir.corp.google.com>
 <20131219144134.GH10855@dhcp22.suse.cz> <20140107162503.f751e880410f61a109cdcc2b@linux-foundation.org> <alpine.DEB.2.02.1401091324120.31538@chino.kir.corp.google.com> <20140109144757.e95616b4280c049b22743a15@linux-foundation.org>
 <alpine.DEB.2.02.1401091551390.20263@chino.kir.corp.google.com> <20140110083025.GE9437@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

On Fri, 10 Jan 2014, Michal Hocko wrote:

> I have already explained why I have acked it. I will not repeat
> it here again. I have also proposed an alternative solution
> (https://lkml.org/lkml/2013/12/12/174) which IMO is more viable because
> it handles both user/kernel memcg OOM consistently. This patch still has
> to be discussed because of other Johannes concerns. I plan to repost it
> in a near future.
> 

This three ring circus has to end.  Really.

Your patch, which is partially based on my suggestion to move the 
mem_cgroup_oom_notify() and call it from two places to support both 
memory.oom_control == 1 and != 1, is something that I liked as you know.  
It's based on my patch which is now removed from -mm.  So if you want to 
rebase that patch and propose it, that's great, but this is yet another 
occurrence of where important patches have been yanked out just before the 
merge window when the problem they are fixing is real and we depend on 
them.

Please post your rebased patch ASAP for the 3.14 merge window.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
