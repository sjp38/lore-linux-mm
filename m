Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7246D6B0253
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 07:35:25 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id xy5so95430668wjc.0
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 04:35:25 -0800 (PST)
Received: from mail-wj0-f195.google.com (mail-wj0-f195.google.com. [209.85.210.195])
        by mx.google.com with ESMTPS id 203si13032712wms.92.2016.12.08.04.35.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 04:35:24 -0800 (PST)
Received: by mail-wj0-f195.google.com with SMTP id j10so26937590wjb.3
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 04:35:23 -0800 (PST)
Date: Thu, 8 Dec 2016 13:35:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, compaction: add vmstats for kcompactd work
Message-ID: <20161208123521.GB26535@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1612071749390.69852@chino.kir.corp.google.com>
 <f25f8fb9-47a9-ebd9-5a7a-95ca6dc324c9@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f25f8fb9-47a9-ebd9-5a7a-95ca6dc324c9@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 08-12-16 09:04:12, Vlastimil Babka wrote:
> On 12/08/2016 02:50 AM, David Rientjes wrote:
> > A "compact_daemon_wake" vmstat exists that represents the number of times
> > kcompactd has woken up.  This doesn't represent how much work it actually
> > did, though.
> > 
> > It's useful to understand how much compaction work is being done by
> > kcompactd versus other methods such as direct compaction and explicitly
> > triggered per-node (or system) compaction.
> > 
> > This adds two new vmstats: "compact_daemon_migrate_scanned" and
> > "compact_daemon_free_scanned" to represent the number of pages kcompactd
> > has scanned as part of its migration scanner and freeing scanner,
> > respectively.
> > 
> > These values are still accounted for in the general
> > "compact_migrate_scanned" and "compact_free_scanned" for compatibility.
> > 
> > It could be argued that explicitly triggered compaction could also be
> > tracked separately, and that could be added if others find it useful.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> A bit of downside is that stats are only updated when compaction finishes,
> but I guess it's acceptable.

Is this really unavoidable though? THe most common usecase for
/proc/vmstat is to collect data over time and perform some statistics to
see how things are going on. Doing this batched accounting will make
these kind of analysis less precise. Cannot we just do the accounting
the same way how we count the reclaim counters?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
