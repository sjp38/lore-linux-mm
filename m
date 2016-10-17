Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 13B4A6B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 07:10:59 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id i187so98664278lfe.4
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 04:10:59 -0700 (PDT)
Received: from mail-lf0-f68.google.com (mail-lf0-f68.google.com. [209.85.215.68])
        by mx.google.com with ESMTPS id 65si18388517ljj.99.2016.10.17.04.10.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 04:10:57 -0700 (PDT)
Received: by mail-lf0-f68.google.com with SMTP id x79so26187588lff.2
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 04:10:57 -0700 (PDT)
Date: Mon, 17 Oct 2016 13:10:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: exclude isolated non-lru pages from
 NR_ISOLATED_ANON or NR_ISOLATED_FILE.
Message-ID: <20161017111055.GG23322@dhcp22.suse.cz>
References: <20161014083219.GA20260@spreadtrum.com>
 <20161014113044.GB6063@dhcp22.suse.cz>
 <20161014134604.GA2179@blaptop>
 <20161014135334.GF6063@dhcp22.suse.cz>
 <20161014144448.GA2899@blaptop>
 <20161014150355.GH6063@dhcp22.suse.cz>
 <20161014152633.GA3157@blaptop>
 <20161015071044.GC9949@dhcp22.suse.cz>
 <20161016230618.GB9196@bbox>
 <20161017084244.GF23322@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161017084244.GF23322@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Ming Ling <ming.ling@spreadtrum.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, vbabka@suse.cz, hannes@cmpxchg.org, baiyaowei@cmss.chinamobile.com, iamjoonsoo.kim@lge.com, rientjes@google.com, hughd@google.com, kirill.shutemov@linux.intel.com, riel@redhat.com, mgorman@suse.de, aquini@redhat.com, corbet@lwn.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, orson.zhai@spreadtrum.com, geng.ren@spreadtrum.com, chunyan.zhang@spreadtrum.com, zhizhou.tian@spreadtrum.com, yuming.han@spreadtrum.com, xiajing@spreadst.com

On Mon 17-10-16 10:42:44, Michal Hocko wrote:
[...]
> Sure, what do you think about the following? I haven't marked it for
> stable because there was no bug report for it AFAIU.

And 0-day robot just noticed that I've screwed and need the following on
top. If the patch makes sense I will repost it to Andrew with this
folded in.
---
diff --git a/mm/compaction.c b/mm/compaction.c
index df1fd0c20e5c..70e6bec46dc2 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -850,7 +850,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/* Successfully isolated */
 		del_page_from_lru_list(page, lruvec, page_lru(page));
-		inc_node_page_state(zone->zone_pgdat,
+		inc_node_page_state(page,
 				NR_ISOLATED_ANON + page_is_file_cache(page));
 
 isolate_success:

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
