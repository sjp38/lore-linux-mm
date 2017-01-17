Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F0676B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 19:42:43 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 201so108511547pfw.5
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 16:42:43 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id m6si1011181pgn.163.2017.01.16.16.42.41
        for <linux-mm@kvack.org>;
        Mon, 16 Jan 2017 16:42:42 -0800 (PST)
Date: Tue, 17 Jan 2017 09:48:40 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 0/5] pro-active compaction
Message-ID: <20170117004840.GA25459@js1304-P5Q-DELUXE>
References: <1484291673-2239-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20170113092420.GF25212@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170113092420.GF25212@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

On Fri, Jan 13, 2017 at 10:24:21AM +0100, Michal Hocko wrote:
> On Fri 13-01-17 16:14:28, Joonsoo Kim wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > Hello,
> > 
> > This is a patchset for pro-active compaction to reduce fragmentation.
> > It is a just RFC patchset so implementation detail isn't good.
> > I submit this for people who want to check the effect of pro-active
> > compaction.
> > 
> > Patch 1 ~ 4 introduces new metric for checking fragmentation. I think
> > that this new metric is useful to check fragmentation state
> > regardless of usefulness of pro-active compaction. Please let me know
> > if someone see that this new metric is useful. I'd like to submit it,
> > separately.
> 
> Could you describe this metric from a high level POV please?

There is some information at description on patch #3.

Anyway, in summary, it is an exponential moving average of unusable free
index which already exists. Unusable free index means the freepage
ratio at the moment that cannot be usable for specific order.
It is easy to understand if you see below equation.

unusable_free_index(order N) = 1 -
  (Number of freepages higher or equal than order N / Total freepages)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
