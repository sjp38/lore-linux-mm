Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 026BE6B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 04:24:26 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c206so13840015wme.3
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 01:24:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d5si10526030wrc.145.2017.01.13.01.24.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 01:24:24 -0800 (PST)
Date: Fri, 13 Jan 2017 10:24:21 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC PATCH 0/5] pro-active compaction
Message-ID: <20170113092420.GF25212@dhcp22.suse.cz>
References: <1484291673-2239-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1484291673-2239-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri 13-01-17 16:14:28, Joonsoo Kim wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Hello,
> 
> This is a patchset for pro-active compaction to reduce fragmentation.
> It is a just RFC patchset so implementation detail isn't good.
> I submit this for people who want to check the effect of pro-active
> compaction.
> 
> Patch 1 ~ 4 introduces new metric for checking fragmentation. I think
> that this new metric is useful to check fragmentation state
> regardless of usefulness of pro-active compaction. Please let me know
> if someone see that this new metric is useful. I'd like to submit it,
> separately.

Could you describe this metric from a high level POV please?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
