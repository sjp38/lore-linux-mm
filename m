Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6E6538E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 09:30:37 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id 201so9696779ywp.13
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 06:30:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z127sor4353304ywb.28.2019.01.28.06.30.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 06:30:36 -0800 (PST)
Date: Mon, 28 Jan 2019 06:30:33 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190128143033.GN50184@devbig004.ftw2.facebook.com>
References: <20190123223144.GA10798@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190123223144.GA10798@chrisdown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Wed, Jan 23, 2019 at 05:31:44PM -0500, Chris Down wrote:
> memory.stat and other files already consider subtrees in their output,
> and we should too in order to not present an inconsistent interface.
> 
> The current situation is fairly confusing, because people interacting
> with cgroups expect hierarchical behaviour in the vein of memory.stat,
> cgroup.events, and other files. For example, this causes confusion when
> debugging reclaim events under low, as currently these always read "0"
> at non-leaf memcg nodes, which frequently causes people to misdiagnose
> breach behaviour. The same confusion applies to other counters in this
> file when debugging issues.
> 
> Aggregation is done at write time instead of at read-time since these
> counters aren't hot (unlike memory.stat which is per-page, so it does it
> at read time), and it makes sense to bundle this with the file
> notifications.
...
> Signed-off-by: Chris Down <chris@chrisdown.name>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Tejun Heo <tj@kernel.org>

Michal has a valid counterpoint that this is a change in userland
visible behavior but to me this patch seems to be more of a bug fix
than anything else in that it's addressing an obvious inconsistency in
the interface.

Thanks.

-- 
tejun
