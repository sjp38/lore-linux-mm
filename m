Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 452FE6B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 03:22:50 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id 203so10694914ith.3
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 00:22:50 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id v2si1695ite.91.2017.03.03.00.22.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 00:22:49 -0800 (PST)
Date: Fri, 3 Mar 2017 09:22:50 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v3] lockdep: Teach lockdep about memalloc_noio_save
Message-ID: <20170303082250.GU6515@twins.programming.kicks-ass.net>
References: <1488367797-27278-1-git-send-email-nborisov@suse.com>
 <20170301154659.GL6515@twins.programming.kicks-ass.net>
 <20170301160529.GI11730@dhcp22.suse.cz>
 <20170301161220.GP6515@twins.programming.kicks-ass.net>
 <20170301161854.GJ11730@dhcp22.suse.cz>
 <20170303080419.GA31582@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170303080419.GA31582@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Nikolay Borisov <nborisov@suse.com>, linux-kernel@vger.kernel.org, vbabka.lkml@gmail.com, linux-mm@kvack.org, mingo@redhat.com

On Fri, Mar 03, 2017 at 09:04:20AM +0100, Michal Hocko wrote:
> On Wed 01-03-17 17:18:54, Michal Hocko wrote:

> > Yes I think it would be better to send it sonner rahter than later.
> > People also might want to backport it to older kernels...
> 
> Would you mind if I took this patch and route it via Andrew? I plan to
> resubmit my scope NOFS patchset [1] and [2] will need to be refreshed on
> top of it so it would be easier for me that way.
> 
> [1] http://lkml.kernel.org/r/20170206140718.16222-1-mhocko@kernel.org
> [2] http://lkml.kernel.org/r/20170206140718.16222-4-mhocko@kernel.org

No real objection, but note that Ingo send out a pull request on the
sched.h split earlier today so double check that it compiles etc..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
