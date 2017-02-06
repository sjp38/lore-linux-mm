Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 274FE6B0253
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 18:40:52 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y143so123989509pfb.6
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 15:40:52 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m1si2156486pln.8.2017.02.06.15.40.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 15:40:51 -0800 (PST)
Date: Mon, 6 Feb 2017 15:40:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] mm, vmscan: consider eligible zones in
 get_scan_count
Message-Id: <20170206154050.ebfaae2883597176606882b7@linux-foundation.org>
In-Reply-To: <20170206081006.GA3085@dhcp22.suse.cz>
References: <20170117103702.28542-1-mhocko@kernel.org>
	<20170117103702.28542-3-mhocko@kernel.org>
	<20170206081006.GA3085@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Trevor Cordes <trevor@tecnopolis.ca>

On Mon, 6 Feb 2017 09:10:07 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> Hi Andrew,
> it turned out that this is not a theoretical issue after all. Trevor
> (added to the CC) was seeing pre-mature OOM killer triggering [1]
> bisected to b2e18757f2c9 ("mm, vmscan: begin reclaiming pages on a
> per-node basis").
> After some going back and forth it turned out that b4536f0c829c ("mm,
> memcg: fix the active list aging for lowmem requests when memcg is
> enabled") helped a lot but it wasn't sufficient on its own. We also
> need this patch to make the oom behavior stable again. So I suggest
> backporting this to stable as well. Could you update the changelog as
> follows?
> 
> The patch would need to be tweaked a bit to apply to 4.10 and older
> but I will do that as soon as it hits the Linus tree in the next merge
> window.
> 
> ...
>
> Fixes: b2e18757f2c9 ("mm, vmscan: begin reclaiming pages on a per-node basis")
> Cc: stable # 4.8+
> Tested-by: Trevor Cordes <trevor@tecnopolis.ca>

No probs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
