Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 629AB6B0253
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 03:26:10 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i124so730574wmf.1
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 00:26:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 32si8120935wrs.205.2017.10.02.00.26.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Oct 2017 00:26:09 -0700 (PDT)
Date: Mon, 2 Oct 2017 09:26:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] mm: oom: show unreclaimable slab info when kernel
 panic
Message-ID: <20171002072607.sjikpsoaiyebmukd@dhcp22.suse.cz>
References: <1506473616-88120-1-git-send-email-yang.s@alibaba-inc.com>
 <1506473616-88120-3-git-send-email-yang.s@alibaba-inc.com>
 <20170927104537.r42javxhnyqlxnqm@dhcp22.suse.cz>
 <ae112574-93c4-22a4-1309-58e585f31493@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ae112574-93c4-22a4-1309-58e585f31493@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 28-09-17 01:25:50, Yang Shi wrote:
> 
> 
> On 9/27/17 3:45 AM, Michal Hocko wrote:
> > On Wed 27-09-17 08:53:35, Yang Shi wrote:
> > > Kernel may panic when oom happens without killable process sometimes it
> > > is caused by huge unreclaimable slabs used by kernel.
> > > 
> > > Although kdump could help debug such problem, however, kdump is not
> > > available on all architectures and it might be malfunction sometime.
> > > And, since kernel already panic it is worthy capturing such information
> > > in dmesg to aid touble shooting.
> > > 
> > > Print out unreclaimable slab info (used size and total size) which
> > > actual memory usage is not zero (num_objs * size != 0) when:
> > >    - unreclaimable slabs : all user memory > unreclaim_slabs_oom_ratio
> > >    - panic_on_oom is set or no killable process
> > 
> > OK, this is better but I do not see why this should be tunable via proc.
> 
> Just thought someone might want to dump unreclaimable slab info
> unconditionally.

If that ever happens then we will eventually add it. But do not add proc
knobs for theoretical usecases. We will have to maintain them and it
can turn into a maint. pain. Like some others in the past.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
