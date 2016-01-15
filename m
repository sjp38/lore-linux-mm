Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1A6B1828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 05:12:23 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id cy9so392795191pac.0
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 02:12:23 -0800 (PST)
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com. [209.85.192.172])
        by mx.google.com with ESMTPS id xp4si15665717pab.1.2016.01.15.02.12.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jan 2016 02:12:22 -0800 (PST)
Received: by mail-pf0-f172.google.com with SMTP id n128so115644387pfn.3
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 02:12:22 -0800 (PST)
Date: Fri, 15 Jan 2016 11:12:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/3] oom, sysrq: Skip over oom victims and killed tasks
Message-ID: <20160115101218.GB14112@dhcp22.suse.cz>
References: <1452632425-20191-1-git-send-email-mhocko@kernel.org>
 <1452632425-20191-2-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1601121639450.28831@chino.kir.corp.google.com>
 <20160113093046.GA28942@dhcp22.suse.cz>
 <alpine.DEB.2.10.1601131633550.3406@chino.kir.corp.google.com>
 <20160114110037.GC29943@dhcp22.suse.cz>
 <alpine.DEB.2.10.1601141347220.16227@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1601141347220.16227@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Thu 14-01-16 13:51:16, David Rientjes wrote:
> I think it's time to kill sysrq+F and I'll send those two patches
> unless there is a usecase I'm not aware of.

I have described one in the part you haven't quoted here. Let me repeat:
: Your system might be trashing to the point you are not able to log in
: and resolve the situation in a reasonable time yet you are still not
: OOM. sysrq+f is your only choice then.

Could you clarify why it is better to ditch a potentially usefull
emergency tool rather than to make it work reliably and predictably?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
