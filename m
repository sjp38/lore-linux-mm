Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B416D6B0007
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 03:36:52 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l4-v6so1329508wmh.0
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 00:36:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m25-v6si2187610edj.287.2018.06.21.00.36.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jun 2018 00:36:51 -0700 (PDT)
Date: Thu, 21 Jun 2018 09:36:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] memcg, oom: move out_of_memory back to the charge
 path
Message-ID: <20180621073646.GB10465@dhcp22.suse.cz>
References: <20180620103736.13880-1-mhocko@kernel.org>
 <20180620151812.GA2441@cmpxchg.org>
 <20180620153148.GO13685@dhcp22.suse.cz>
 <20180620193836.GB4734@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180620193836.GB4734@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 20-06-18 15:38:36, Johannes Weiner wrote:
> On Wed, Jun 20, 2018 at 05:31:48PM +0200, Michal Hocko wrote:
> > 	 * Please note that mem_cgroup_oom_synchronize might fail to find a
> > 	 * victim and then we have rely on mem_cgroup_oom_synchronize otherwise
> > 	 * we would fall back to the global oom killer in pagefault_out_of_memory
> 
> I can't quite figure out what this paragraph is trying to
> say. "oom_synchronize might fail [...] and we have to rely on
> oom_synchronize". Hm?

heh, vim autocompletion + a stale comment from the previous
implementation which ENOMEM on the fail path. I went with 

	 * Please note that mem_cgroup_out_of_memory might fail to find a
	 * victim and then we have to bail out from the charge path.

-- 
Michal Hocko
SUSE Labs
