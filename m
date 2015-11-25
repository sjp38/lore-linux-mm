Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD566B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 09:30:16 -0500 (EST)
Received: by wmec201 with SMTP id c201so72543389wme.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 06:30:14 -0800 (PST)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id i1si35056408wjq.10.2015.11.25.06.30.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 06:30:13 -0800 (PST)
Received: by wmww144 with SMTP id w144so71662420wmw.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 06:30:13 -0800 (PST)
Date: Wed, 25 Nov 2015 15:30:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/9] page_owner improvements for debugging
Message-ID: <20151125143010.GI27283@dhcp22.suse.cz>
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On Tue 24-11-15 13:36:12, Vlastimil Babka wrote:
[...]
> For the last point, Kirill requested a human readable printing of gfp_mask and
> migratetype after v1. At that point it probably makes a lot of sense to do the
> same for page alloc failure and OOM warnings. The flags have been undergoing
> revisions recently, and we might be getting reports from various kernel
> versions that differ. The ./scripts/gfp-translate tool needs to be pointed at
> the corresponding sources to be accurate.  The downside is potentially breaking
> scripts that grep these warnings, but it's not a first change done there over
> the years.

Yes this is very helpful! Thanks for doing this.
 
> Note I'm not entirely happy about the dump_gfpflag_names() implementation, due
> to usage of pr_cont() unreliable on SMP (and I've seen spurious newlines in
> dmesg output, while being correct on serial console or /var/log/messages).
> It also doesn't allow plugging the gfp_mask translation into
> /sys/kernel/debug/page_owner where it also could make sense. Maybe a new
> *printf formatting flag?

I wouldn't object. gfp_mask has its own "type" so having a specific
formatter sounds like a good idea to me.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
