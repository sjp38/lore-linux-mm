Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id ABD4E6B0036
	for <linux-mm@kvack.org>; Tue, 13 May 2014 18:25:58 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id rd3so800242pab.29
        for <linux-mm@kvack.org>; Tue, 13 May 2014 15:25:58 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id qe5si8621779pbc.496.2014.05.13.15.25.57
        for <linux-mm@kvack.org>;
        Tue, 13 May 2014 15:25:57 -0700 (PDT)
Date: Tue, 13 May 2014 15:25:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 05/19] mm: page_alloc: Calculate classzone_idx once from
 the zonelist ref
Message-Id: <20140513152556.d14e3eaff8949a7010c02686@linux-foundation.org>
In-Reply-To: <1399974350-11089-6-git-send-email-mgorman@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
	<1399974350-11089-6-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Tue, 13 May 2014 10:45:36 +0100 Mel Gorman <mgorman@suse.de> wrote:

> There is no need to calculate zone_idx(preferred_zone) multiple times
> or use the pgdat to figure it out.
> 

This one falls afoul of pending mm/next changes in non-trivial ways.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
