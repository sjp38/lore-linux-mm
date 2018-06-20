Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1DC6B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 15:36:11 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id t7-v6so446360wmg.3
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 12:36:11 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b26-v6si1453327edr.445.2018.06.20.12.36.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Jun 2018 12:36:10 -0700 (PDT)
Date: Wed, 20 Jun 2018 15:38:36 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH] memcg, oom: move out_of_memory back to the charge
 path
Message-ID: <20180620193836.GB4734@cmpxchg.org>
References: <20180620103736.13880-1-mhocko@kernel.org>
 <20180620151812.GA2441@cmpxchg.org>
 <20180620153148.GO13685@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180620153148.GO13685@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 20, 2018 at 05:31:48PM +0200, Michal Hocko wrote:
> 	 * Please note that mem_cgroup_oom_synchronize might fail to find a
> 	 * victim and then we have rely on mem_cgroup_oom_synchronize otherwise
> 	 * we would fall back to the global oom killer in pagefault_out_of_memory

I can't quite figure out what this paragraph is trying to
say. "oom_synchronize might fail [...] and we have to rely on
oom_synchronize". Hm?
