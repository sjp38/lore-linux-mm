Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D766E6B0006
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 04:00:44 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i26-v6so534502edr.4
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 01:00:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y10-v6si1041433edq.450.2018.08.02.01.00.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 01:00:43 -0700 (PDT)
Date: Thu, 2 Aug 2018 10:00:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] introduce memory.oom.group
Message-ID: <20180802080041.GB10808@dhcp22.suse.cz>
References: <20180730180100.25079-1-guro@fb.com>
 <alpine.DEB.2.21.1807301847000.198273@chino.kir.corp.google.com>
 <20180731235135.GA23436@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1808011437350.38896@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1808011437350.38896@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Wed 01-08-18 14:51:25, David Rientjes wrote:
> On Tue, 31 Jul 2018, Roman Gushchin wrote:
> 
> > > What's the plan with the cgroup aware oom killer?  It has been sitting in 
> > > the -mm tree for ages with no clear path to being merged.
> > 
> > It's because your nack, isn't it?
> > Everybody else seem to be fine with it.
> > 
> 
> If they are fine with it, I'm not sure they have tested it :)  Killing 
> entire cgroups needlessly for mempolicy oom kills that will not free 
> memory on target nodes is the first regression they may notice.

I do not remember you would be mentioning this previously. Anyway the
older implementation has considered the nodemask in memcg_oom_badness.
You are right that a cpuset allocation could needlessly select a memcg
with small or no memory from the target nodemask which is something I
could have noticed during the review. If only I didn't have to spend all
my energy to go through repetitive arguments of yours. Anyway this would
be quite trivial to resolve in the same function by checking
node_isset(node, current->mems_allowed).

Thanks for your productive feedback again.

Skipping the rest which is yet again repeating same arguments and it
doesn't add anything new to the table.
-- 
Michal Hocko
SUSE Labs
