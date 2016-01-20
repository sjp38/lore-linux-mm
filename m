Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id DAF076B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 04:49:40 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id b14so19841780wmb.1
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 01:49:40 -0800 (PST)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id b2si52363754wjy.233.2016.01.20.01.49.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 01:49:39 -0800 (PST)
Received: by mail-wm0-f43.google.com with SMTP id r129so123592895wmr.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 01:49:39 -0800 (PST)
Date: Wed, 20 Jan 2016 10:49:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/3] oom, sysrq: Skip over oom victims and killed tasks
Message-ID: <20160120094938.GB14187@dhcp22.suse.cz>
References: <1452632425-20191-1-git-send-email-mhocko@kernel.org>
 <1452632425-20191-2-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1601121639450.28831@chino.kir.corp.google.com>
 <20160113093046.GA28942@dhcp22.suse.cz>
 <alpine.DEB.2.10.1601131633550.3406@chino.kir.corp.google.com>
 <20160114110037.GC29943@dhcp22.suse.cz>
 <alpine.DEB.2.10.1601141347220.16227@chino.kir.corp.google.com>
 <20160115101218.GB14112@dhcp22.suse.cz>
 <alpine.DEB.2.10.1601191454160.7346@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1601191454160.7346@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Tue 19-01-16 14:57:33, David Rientjes wrote:
> On Fri, 15 Jan 2016, Michal Hocko wrote:
> 
> > > I think it's time to kill sysrq+F and I'll send those two patches
> > > unless there is a usecase I'm not aware of.
> > 
> > I have described one in the part you haven't quoted here. Let me repeat:
> > : Your system might be trashing to the point you are not able to log in
> > : and resolve the situation in a reasonable time yet you are still not
> > : OOM. sysrq+f is your only choice then.
> > 
> > Could you clarify why it is better to ditch a potentially usefull
> > emergency tool rather than to make it work reliably and predictably?
> 
> I'm concerned about your usecase where the kernel requires admin 
> intervention to resolve such an issue and there is nothing in the VM we 
> can do to fix it.
> 
> If you have a specific test that demonstrates when your usecase is needed, 
> please provide it so we can address the issue that it triggers.

No, I do not have a specific load in mind. But let's be realistic. There
will _always_ be corner cases where the VM cannot react properly or in a
timely fashion.

> I'd prefer to fix the issue in the VM rather than require human
> intervention, especially when we try to keep a very large number of
> machines running in our datacenters.

It is always preferable to resolve the mm related issue automagically,
of course. We should strive for robustness as much as possible but that
doesn't mean we should get the only emergency tool out of administrator
hands.

To be honest I really fail to understand your line of argumentation
here. Just that you think that sysrq+f might be not helpful in large
datacenters which you seem to care about, doesn't mean that it is not
helpful in other setups.

Removing the functionality is out of question IMHO so can we please
start discussing how to make it more predictable please?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
