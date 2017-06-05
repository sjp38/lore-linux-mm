Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id DDEA06B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 01:37:05 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id v14so3439823wmf.6
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 22:37:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 188si10936506wmf.101.2017.06.04.22.37.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Jun 2017 22:37:04 -0700 (PDT)
Date: Mon, 5 Jun 2017 07:37:01 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Message-ID: <20170605053701.GA9773@dhcp22.suse.cz>
References: <20170602071818.GA29840@dhcp22.suse.cz>
 <201706022013.DCI34351.SHOLFFtJQOMFOV@I-love.SAKURA.ne.jp>
 <CAM_iQpWC9E=hee9xYY7Z4_oAA3wK5VOAve-Q1nMD_1SOXJmiyw@mail.gmail.com>
 <201706041758.DGG86904.SOOVLtMJFOQFFH@I-love.SAKURA.ne.jp>
 <20170604150533.GA3500@dhcp22.suse.cz>
 <201706050643.EDD87569.VSFQOFJtFHOOML@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201706050643.EDD87569.VSFQOFJtFHOOML@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: xiyou.wangcong@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz

On Mon 05-06-17 06:43:04, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> >                                          The first and the most
> > important one is whether this is reproducible with the _clean_ vanilla
> > kernel.
> 
> At this point, distribution kernel users won't get any help from community,
> nor distribution kernel users won't be able to help community.

Running a distribution kernel is at risk that obscure bugs (like this
one) will be asked to be reproduced on the vanilla kernel. I work to
support a distribution kernel as well and I can tell you that I always
do my best reproducing or at least pinpointing the issue before
reporting it upstream. People working on the upstream kernel are quite
busy and _demanding_ a support for something that should come from their
vendor is a bit to much.

> Even more, you are asking that whether this is reproducible with the clean
> _latest_ (linux-next.git or at least linux.git) vanilla kernel. Therefore,
> only quite few kernel developers can involve this problem, for not everybody
> is good at establishing environments / steps for reproducing this problem.
> It makes getting feedback even more difficult.

Come on. This is clearly an artificial test executed pretty much
intentionally with a known setup.
 
> According to your LSFMM session ( https://lwn.net/Articles/718212/ ),
> you are worrying about out of reviewers. But it seems to me that your
> orientation keeps the gap between developers and users wider; only
> experienced developers like you know almost all things, all others will
> know almost nothing.

I am really tired of your constant accusations. I think I have a pretty
good track record in trying to help with as many bugs reported as
possible. You keep hammering one particular part of the kernel and
consider it alpha and omega of everything. I disagree because I would
rather concentrate on something that actually matters in day to day user
workloads. I have already tried to explain that to you several times but
you just seem to ignore that so I will not waste my time more...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
