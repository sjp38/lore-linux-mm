Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1D3536B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 16:25:27 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id r74so1310606wrb.7
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 13:25:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z196si205770wmd.200.2017.09.25.13.25.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Sep 2017 13:25:25 -0700 (PDT)
Date: Mon, 25 Sep 2017 22:25:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170925202442.lmcmvqwy2jj2tr5h@dhcp22.suse.cz>
References: <20170913215607.GA19259@castle>
 <20170914134014.wqemev2kgychv7m5@dhcp22.suse.cz>
 <20170914160548.GA30441@castle>
 <20170915105826.hq5afcu2ij7hevb4@dhcp22.suse.cz>
 <20170915152301.GA29379@castle>
 <20170918061405.pcrf5vauvul4c2nr@dhcp22.suse.cz>
 <20170920215341.GA5382@castle>
 <20170925122400.4e7jh5zmuzvbggpe@dhcp22.suse.cz>
 <20170925170004.GA22704@cmpxchg.org>
 <20170925181533.GA15918@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170925181533.GA15918@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 25-09-17 19:15:33, Roman Gushchin wrote:
[...]
> I'm not against this model, as I've said before. It feels logical,
> and will work fine in most cases.
> 
> In this case we can drop any mount/boot options, because it preserves
> the existing behavior in the default configuration. A big advantage.

I am not sure about this. We still need an opt-in, ragardless, because
selecting the largest process from the largest memcg != selecting the
largest task (just consider memcgs with many processes example).

> The only thing, I'm slightly concerned, that due to the way how we calculate
> the memory footprint for tasks and memory cgroups, we will have a number
> of weird edge cases. For instance, when putting a single process into
> the group_oom memcg will alter the oom_score significantly and result
> in significantly different chances to be killed. An obvious example will
> be a task with oom_score_adj set to any non-extreme (other than 0 and -1000)
> value, but it can also happen in case of constrained alloc, for instance.

I am not sure I understand. Are you talking about root memcg comparing
to other memcgs?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
