Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C5B696B0006
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 16:26:18 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v14so1422181pgq.11
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 13:26:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bj5-v6sor1093606plb.12.2018.03.20.13.26.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Mar 2018 13:26:17 -0700 (PDT)
Date: Tue, 20 Mar 2018 13:26:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, page_alloc: wakeup kcompactd even if kswapd cannot
 free more memory
In-Reply-To: <224545ab-9859-6f37-f58a-d5e04371258c@suse.cz>
Message-ID: <alpine.DEB.2.20.1803201325530.167205@chino.kir.corp.google.com>
References: <alpine.DEB.2.20.1803111659420.209721@chino.kir.corp.google.com> <224545ab-9859-6f37-f58a-d5e04371258c@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 20 Mar 2018, Vlastimil Babka wrote:

> > Kswapd will not wakeup if per-zone watermarks are not failing or if too
> > many previous attempts at background reclaim have failed.
> > 
> > This can be true if there is a lot of free memory available.  For high-
> > order allocations, kswapd is responsible for waking up kcompactd for
> > background compaction.  If the zone is now below its watermarks or
>                                          not ?
> 

Good catch, Andrew please let me know if you would like a resend to 
correct this.
