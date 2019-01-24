Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4568E0068
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 20:06:41 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id p7so2016224yba.2
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 17:06:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y11sor7577812ybr.188.2019.01.23.17.06.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 17:06:40 -0800 (PST)
Date: Wed, 23 Jan 2019 20:06:38 -0500
From: Chris Down <chris@chrisdown.name>
Subject: Re: [PATCH 1/2] mm: Rename ambiguously named memory.stat counters
 and functions
Message-ID: <20190124010638.GB9055@chrisdown.name>
References: <20190123223049.GA9149@chrisdown.name>
 <20190123235940.GA21563@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190123235940.GA21563@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Dennis Zhou <dennis@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Kernel Team <Kernel-team@fb.com>

Roman Gushchin writes:
>I'd personally go with memcg_vmstat_percpu. Not insisting,
>but you end up using both vmstat and vmstats, which isn't very
>consistent.

Yeah, we also have similar naming in accumulated_vmstats. Hmm, let me think 
about this a bit and get back to you tomorrow. The main bit I was concerned 
about was memory_events vs. events -- I don't really have strong opinions on 
the percpu struct's exact naming/plurality.

>Other than that looks good to me. Please, feel free to add
>Acked-by: Roman Gushchin <guro@fb.com>

Thanks!
