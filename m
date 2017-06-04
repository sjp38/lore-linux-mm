Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 46D566B0292
	for <linux-mm@kvack.org>; Sun,  4 Jun 2017 17:43:26 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id h127so146931130oic.11
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 14:43:26 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z37si11848329otc.51.2017.06.04.14.43.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Jun 2017 14:43:23 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170602071818.GA29840@dhcp22.suse.cz>
	<201706022013.DCI34351.SHOLFFtJQOMFOV@I-love.SAKURA.ne.jp>
	<CAM_iQpWC9E=hee9xYY7Z4_oAA3wK5VOAve-Q1nMD_1SOXJmiyw@mail.gmail.com>
	<201706041758.DGG86904.SOOVLtMJFOQFFH@I-love.SAKURA.ne.jp>
	<20170604150533.GA3500@dhcp22.suse.cz>
In-Reply-To: <20170604150533.GA3500@dhcp22.suse.cz>
Message-Id: <201706050643.EDD87569.VSFQOFJtFHOOML@I-love.SAKURA.ne.jp>
Date: Mon, 5 Jun 2017 06:43:04 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: xiyou.wangcong@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz

Michal Hocko wrote:
> On Sun 04-06-17 17:58:49, Tetsuo Handa wrote:
> [...]
> > > As I already mentioned in my original report, I know there are at least
> > > two similar warnings reported before:
> > >
> > > https://lkml.org/lkml/2016/12/13/529
> > > https://bugzilla.kernel.org/show_bug.cgi?id=192981
> > >
> > > I don't see any fix, nor I see they are similar to mine.
> > 
> > No means for analyzing, no plan for fixing the problems.
> 
> Stop this bullshit Tetsuo! Seriously, you are getting over the line!
> Nobody said we do not care. In order to do something about that we need
> to get further and relevant information.

What I'm asking for is the method for getting further and relevant
information. And I get no positive feedback nor usable alternatives.

>                                          The first and the most
> important one is whether this is reproducible with the _clean_ vanilla
> kernel.

At this point, distribution kernel users won't get any help from community,
nor distribution kernel users won't be able to help community.

Even more, you are asking that whether this is reproducible with the clean
_latest_ (linux-next.git or at least linux.git) vanilla kernel. Therefore,
only quite few kernel developers can involve this problem, for not everybody
is good at establishing environments / steps for reproducing this problem.
It makes getting feedback even more difficult.

According to your LSFMM session ( https://lwn.net/Articles/718212/ ),
you are worrying about out of reviewers. But it seems to me that your
orientation keeps the gap between developers and users wider; only
experienced developers like you know almost all things, all others will
know almost nothing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
