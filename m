Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id D07026B0005
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 17:33:21 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f5-v6so4167280plf.18
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 14:33:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x70-v6si15498948pfj.347.2018.06.18.14.33.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 14:33:20 -0700 (PDT)
Date: Mon, 18 Jun 2018 14:33:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 6/7] mm, proc: add KReclaimable to /proc/meminfo
Message-Id: <20180618143317.eb8f5d7b6c667784343ef902@linux-foundation.org>
In-Reply-To: <20180618091808.4419-7-vbabka@suse.cz>
References: <20180618091808.4419-1-vbabka@suse.cz>
	<20180618091808.4419-7-vbabka@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>

On Mon, 18 Jun 2018 11:18:07 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> The vmstat NR_KERNEL_MISC_RECLAIMABLE counter is for kernel non-slab
> allocations that can be reclaimed via shrinker. In /proc/meminfo, we can show
> the sum of all reclaimable kernel allocations (including slab) as
> "KReclaimable". Add the same counter also to per-node meminfo under /sys

Why do you consider this useful enough to justify adding it to
/pro/meminfo?  How will people use it, what benefit will they see, etc?


Maybe you've undersold this whole patchset, but I'm struggling a bit to
see what the end-user benefits are.  What would be wrong with just
sticking with what we have now?
