Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 988CB6B0033
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 11:00:08 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id i6so13310948wre.6
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 08:00:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t67si3846555wmg.85.2018.01.17.08.00.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Jan 2018 08:00:07 -0800 (PST)
Date: Wed, 17 Jan 2018 17:00:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm 3/4] mm, memcg: replace memory.oom_group with policy
 tunable
Message-ID: <20180117160004.GH2900@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801161814130.28198@chino.kir.corp.google.com>
 <20180117154155.GU3460072@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180117154155.GU3460072@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 17-01-18 07:41:55, Tejun Heo wrote:
> Hello, David.
> 
> On Tue, Jan 16, 2018 at 06:15:08PM -0800, David Rientjes wrote:
> > The behavior of killing an entire indivisible memory consumer, enabled
> > by memory.oom_group, is an oom policy itself.  It specifies that all
> 
> I thought we discussed this before but maybe I'm misremembering.
> There are two parts to the OOM policy.  One is victim selection, the
> other is the action to take thereafter.

Yes we have. Multiple times! The last time I've said the very same thing
was yesterday http://lkml.kernel.org/r/20180116220907.GD17351@dhcp22.suse.cz

> The two are different and conflating the two don't work too well.  For
> example, please consider what should be given to the delegatee when
> delegating a subtree, which often is a good excercise when designing
> these APIs.

Absolutely agreed! And moreover, there are not all that many ways what
to do as an action. You just kill a logical entity - be it a process or
a logical group of processes. But you have way too many policies how
to select that entity. Do you want to chose the youngest process/group
because all the older ones have been computing real stuff and you would
lose days of your cpu time? Or should those who pay more should be
protected (aka give them static priorities), or you name it...

I am sorry, I still didn't grasp the full semantic of the proposed
soluton but the mere fact it is starting by conflating selection and the
action is a no go and a wrong API. This is why I've said that what you
(David) outlined yesterday is probably going to suffer from a much
longer discussion and most likely to be not acceptable. Your patchset
proves me correct...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
