Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 44A6C6B0038
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 11:00:29 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id k19so62863008iod.4
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 08:00:29 -0800 (PST)
Received: from mail-it0-x231.google.com (mail-it0-x231.google.com. [2607:f8b0:4001:c0b::231])
        by mx.google.com with ESMTPS id e40si20046888ioi.250.2016.11.22.08.00.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 08:00:28 -0800 (PST)
Received: by mail-it0-x231.google.com with SMTP id l8so12746370iti.1
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 08:00:28 -0800 (PST)
Subject: Re: [PATCH] block,blkcg: use __GFP_NOWARN for best-effort allocations
 in blkcg
References: <20161121154336.GD19750@merlins.org>
 <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
 <20161121215639.GF13371@merlins.org> <20161121230332.GA3767@htj.duckdns.org>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <552f51ad-bf74-567d-63ee-afda4d121797@kernel.dk>
Date: Tue, 22 Nov 2016 09:00:24 -0700
MIME-Version: 1.0
In-Reply-To: <20161121230332.GA3767@htj.duckdns.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Marc MERLIN <marc@merlins.org>

On 11/21/2016 04:03 PM, Tejun Heo wrote:
> blkcg allocates some per-cgroup data structures with GFP_NOWAIT and
> when that fails falls back to operations which aren't specific to the
> cgroup.  Occassional failures are expected under pressure and falling
> back to non-cgroup operation is the right thing to do.
>
> Unfortunately, I forgot to add __GFP_NOWARN to these allocations and
> these expected failures end up creating a lot of noise.  Add
> __GFP_NOWARN.

Thanks Tejun, added for 4.10.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
