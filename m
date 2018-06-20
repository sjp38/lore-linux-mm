Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6F3536B0006
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 11:34:41 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id n21-v6so74020wmc.4
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 08:34:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x4-v6si1149546wmg.226.2018.06.20.08.34.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jun 2018 08:34:40 -0700 (PDT)
Date: Wed, 20 Jun 2018 17:34:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] memcg, oom: move out_of_memory back to the charge
 path
Message-ID: <20180620153438.GP13685@dhcp22.suse.cz>
References: <20180620103736.13880-1-mhocko@kernel.org>
 <20180620151812.GA2441@cmpxchg.org>
 <20180620153148.GO13685@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180620153148.GO13685@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 20-06-18 17:31:48, Michal Hocko wrote:
> On Wed 20-06-18 11:18:12, Johannes Weiner wrote:
[...]
> > 1) Why warn for kernel allocations, but not userspace ones? This
> > should have a comment at least.
> 
> I am not sure I understand. We do warn for all allocations types of
> mem_cgroup_out_of_memory fails as long as we are not in a legacy -
> oom_disabled case.

OK, I can see it now. It wasn't in the quoted context and I just forgot
that WARN(!current->memcg_may_oom, ...). Well, I do not remember why
I've made it conditional and you are right it doesn't make any sense.
Probably a different code flow back then.

Updated to warn regardless of memcg_may_oom.
-- 
Michal Hocko
SUSE Labs
