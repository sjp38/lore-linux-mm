Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3DAF86B0299
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 04:15:45 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id a2so3607537lfh.4
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 01:15:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q21sor142136lfj.85.2017.11.07.01.15.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Nov 2017 01:15:43 -0800 (PST)
Date: Tue, 7 Nov 2017 12:15:40 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 1/3] mm: memcontrol: eliminate raw access to stat and
 event counters
Message-ID: <20171107091540.mmv2htftez3ffle4@esperanza>
References: <20171103153336.24044-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171103153336.24044-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Fri, Nov 03, 2017 at 11:33:34AM -0400, Johannes Weiner wrote:
> Replace all raw 'this_cpu_' modifications of the stat and event
> per-cpu counters with API functions such as mod_memcg_state().
> 
> This makes the code easier to read, but is also in preparation for the
> next patch, which changes the per-cpu implementation of those counters.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/memcontrol.h | 31 +++++++++++++++---------
>  mm/memcontrol.c            | 59 ++++++++++++++++++++--------------------------
>  2 files changed, 45 insertions(+), 45 deletions(-)

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
