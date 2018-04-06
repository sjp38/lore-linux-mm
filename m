Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 41EAD6B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 12:07:37 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p18so1101760wmh.2
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 09:07:37 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id x12si8124009edi.274.2018.04.06.09.07.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 06 Apr 2018 09:07:35 -0700 (PDT)
Date: Fri, 6 Apr 2018 12:08:57 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 1/4] mm/vmscan: Update stale comments
Message-ID: <20180406160857.GB20806@cmpxchg.org>
References: <20180323152029.11084-1-aryabinin@virtuozzo.com>
 <20180323152029.11084-2-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180323152029.11084-2-aryabinin@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Shakeel Butt <shakeelb@google.com>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Fri, Mar 23, 2018 at 06:20:26PM +0300, Andrey Ryabinin wrote:
> Update some comments that become stale since transiton from per-zone
> to per-node reclaim.
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
