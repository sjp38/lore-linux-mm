Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id BA6E86B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 19:01:56 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id 65so12789173pff.2
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 16:01:56 -0800 (PST)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id e29si58370032pfj.102.2016.01.20.16.01.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 16:01:56 -0800 (PST)
Received: by mail-pf0-x234.google.com with SMTP id e65so12869106pfe.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 16:01:55 -0800 (PST)
Date: Wed, 20 Jan 2016 16:01:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 1/3] oom, sysrq: Skip over oom victims and killed tasks
In-Reply-To: <20160120094938.GB14187@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1601201550060.18155@chino.kir.corp.google.com>
References: <1452632425-20191-1-git-send-email-mhocko@kernel.org> <1452632425-20191-2-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1601121639450.28831@chino.kir.corp.google.com> <20160113093046.GA28942@dhcp22.suse.cz> <alpine.DEB.2.10.1601131633550.3406@chino.kir.corp.google.com>
 <20160114110037.GC29943@dhcp22.suse.cz> <alpine.DEB.2.10.1601141347220.16227@chino.kir.corp.google.com> <20160115101218.GB14112@dhcp22.suse.cz> <alpine.DEB.2.10.1601191454160.7346@chino.kir.corp.google.com> <20160120094938.GB14187@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Wed, 20 Jan 2016, Michal Hocko wrote:

> No, I do not have a specific load in mind. But let's be realistic. There
> will _always_ be corner cases where the VM cannot react properly or in a
> timely fashion.
> 

Then let's identify it and fix it, like we do with any other bug?  I'm 99% 
certain you are not advocating that human intervention is the ideal 
solution to prevent lengthy stalls or livelocks.

I can't speak for all possible configurations and workloads; the only 
thing we use sysrq+f for is automated testing of the oom killer itself.  
It would help to know of any situations when people actually need to use 
this to solve issues and then fix those issues rather than insisting that 
this is the ideal solution.

> To be honest I really fail to understand your line of argumentation
> here. Just that you think that sysrq+f might be not helpful in large
> datacenters which you seem to care about, doesn't mean that it is not
> helpful in other setups.
> 

This type of message isn't really contributing anything.  You don't have a 
specific load in mind, you can't identify a pending bug that people have 
complained about, you presumably can't show a testcase that demonstrates 
how it's required, yet you're arguing that we should keep a debugging tool 
around because you think somebody somewhere sometime might use it.

 [ I would imagine that users would be unhappy they have to kill processes 
   already, and would have reported how ridiculous it is that they had to
   use sysrq+f, but I haven't seen those bug reports. ]

I want the VM to be responsive, I don't want it to thrash forever, and I 
want it to not require root to trigger a sysrq to have the kernel kill a 
process for the VM to work properly.  We either need to fix the issue that 
causes the unresponsiveness or oom kill processes earlier.  This is very 
simple.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
