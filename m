Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F8DC6B05F4
	for <linux-mm@kvack.org>; Thu, 10 May 2018 07:41:52 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w7-v6so1038934pfd.9
        for <linux-mm@kvack.org>; Thu, 10 May 2018 04:41:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w9-v6si619166plp.389.2018.05.10.04.41.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 May 2018 04:41:50 -0700 (PDT)
Date: Thu, 10 May 2018 13:41:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: fix oom_kill event handling
Message-ID: <20180510114147.GB5325@dhcp22.suse.cz>
References: <20180508124637.29984-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180508124637.29984-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Tue 08-05-18 13:46:37, Roman Gushchin wrote:
> Commit e27be240df53 ("mm: memcg: make sure memory.events is
> uptodate when waking pollers") converted most of memcg event
> counters to per-memcg atomics, which made them less confusing
> for a user. The "oom_kill" counter remained untouched, so now
> it behaves differently than other counters (including "oom").
> This adds nothing but confusion.
> 
> Let's fix this by adding the MEMCG_OOM_KILL event, and follow
> the MEMCG_OOM approach. This also removes a hack from
> count_memcg_event_mm(), introduced earlier specially for the
> OOM_KILL counter.

I agree that the current OOM_KILL is confusing. But do we really need
another memcg_memory_event_mm helper used for only one counter rather
than reuse memcg_memory_event. __oom_kill_process doesn't have the memcg
but nothing should really prevent us from adding the context
(oom_control) there, no?

[...]
-- 
Michal Hocko
SUSE Labs
