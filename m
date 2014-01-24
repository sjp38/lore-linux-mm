Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 830ED6B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 17:30:07 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fa1so3759331pad.13
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 14:30:07 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ye6si2598334pbc.200.2014.01.24.14.30.05
        for <linux-mm@kvack.org>;
        Fri, 24 Jan 2014 14:30:06 -0800 (PST)
Date: Fri, 24 Jan 2014 14:30:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/2] mm: reduce reclaim stalls with heavy anon and dirty
 cache
Message-Id: <20140124143003.2629e9c2c8c2595e805c8c25@linux-foundation.org>
In-Reply-To: <1390600984-13925-1-git-send-email-hannes@cmpxchg.org>
References: <1390600984-13925-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 24 Jan 2014 17:03:02 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> Tejun reported stuttering and latency spikes on a system where random
> tasks would enter direct reclaim and get stuck on dirty pages.  Around
> 50% of memory was occupied by tmpfs backed by an SSD, and another disk
> (rotating) was reading and writing at max speed to shrink a partition.

Do you think this is serious enough to squeeze these into 3.14?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
