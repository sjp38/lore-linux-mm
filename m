Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 969146B0253
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 17:57:36 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id yy13so366029600pab.3
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 14:57:36 -0800 (PST)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id wc6si10419132pab.33.2016.01.19.14.57.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 14:57:35 -0800 (PST)
Received: by mail-pf0-x236.google.com with SMTP id e65so183363611pfe.0
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 14:57:35 -0800 (PST)
Date: Tue, 19 Jan 2016 14:57:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 1/3] oom, sysrq: Skip over oom victims and killed tasks
In-Reply-To: <20160115101218.GB14112@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1601191454160.7346@chino.kir.corp.google.com>
References: <1452632425-20191-1-git-send-email-mhocko@kernel.org> <1452632425-20191-2-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1601121639450.28831@chino.kir.corp.google.com> <20160113093046.GA28942@dhcp22.suse.cz> <alpine.DEB.2.10.1601131633550.3406@chino.kir.corp.google.com>
 <20160114110037.GC29943@dhcp22.suse.cz> <alpine.DEB.2.10.1601141347220.16227@chino.kir.corp.google.com> <20160115101218.GB14112@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Fri, 15 Jan 2016, Michal Hocko wrote:

> > I think it's time to kill sysrq+F and I'll send those two patches
> > unless there is a usecase I'm not aware of.
> 
> I have described one in the part you haven't quoted here. Let me repeat:
> : Your system might be trashing to the point you are not able to log in
> : and resolve the situation in a reasonable time yet you are still not
> : OOM. sysrq+f is your only choice then.
> 
> Could you clarify why it is better to ditch a potentially usefull
> emergency tool rather than to make it work reliably and predictably?

I'm concerned about your usecase where the kernel requires admin 
intervention to resolve such an issue and there is nothing in the VM we 
can do to fix it.

If you have a specific test that demonstrates when your usecase is needed, 
please provide it so we can address the issue that it triggers.  I'd 
prefer to fix the issue in the VM rather than require human intervention, 
especially when we try to keep a very large number of machines running in 
our datacenters.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
