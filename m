Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0FD7D6B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 16:50:26 -0500 (EST)
Received: by wmww144 with SMTP id w144so148524587wmw.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 13:50:25 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id je3si26527388wjb.14.2015.11.30.13.50.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 13:50:25 -0800 (PST)
Date: Mon, 30 Nov 2015 16:50:07 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 09/13] mm: memcontrol: generalize the socket accounting
 jump label
Message-ID: <20151130215007.GA31903@cmpxchg.org>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
 <1448401925-22501-10-git-send-email-hannes@cmpxchg.org>
 <565CBAC2.3080804@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <565CBAC2.3080804@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Baron <jbaron@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, "peterz@infradead.org" <peterz@infradead.org>

On Mon, Nov 30, 2015 at 04:08:18PM -0500, Jason Baron wrote:
> We're trying to move to the updated API, so this should be:
> static_branch_unlikely(&memcg_sockets_enabled_key)
> 
> see: include/linux/jump_label.h for details.

Good point. There is another struct static_key in there as well. How
about the following on top of this series?

---
