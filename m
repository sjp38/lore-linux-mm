Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A77886B0005
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 14:41:34 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z22so2217597pfi.7
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 11:41:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g19sor479963pfb.70.2018.04.27.11.41.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 27 Apr 2018 11:41:33 -0700 (PDT)
Date: Fri, 27 Apr 2018 11:41:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: don't show nr_indirectly_reclaimable in
 /proc/vmstat
In-Reply-To: <99208563-1171-b7e7-a0d7-b47b6c5e2307@suse.cz>
Message-ID: <alpine.DEB.2.21.1804271139500.152082@chino.kir.corp.google.com>
References: <20180425191422.9159-1-guro@fb.com> <20180426200331.GZ17484@dhcp22.suse.cz> <alpine.DEB.2.21.1804261453460.238822@chino.kir.corp.google.com> <99208563-1171-b7e7-a0d7-b47b6c5e2307@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, kernel-team@fb.com, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>

On Fri, 27 Apr 2018, Vlastimil Babka wrote:

> It was in the original thread, see e.g.
> <08524819-14ef-81d0-fa90-d7af13c6b9d5@suse.cz>
> 
> However it will take some time to get that in mainline, and meanwhile
> the current implementation does prevent a DOS. So I doubt it can be
> fully reverted - as a compromise I just didn't want the counter to
> become ABI. TBH though, other people at LSF/MM didn't seem concerned
> that /proc/vmstat is an ABI that we can't change (i.e. counters have
> been presumably removed in the past already).
> 

What prevents this from being a simple atomic_t that gets added to in 
__d_alloc(), subtracted from in __d_free_external_name(), and read in 
si_mem_available() and __vm_enough_memory()?
