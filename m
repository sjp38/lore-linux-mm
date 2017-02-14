Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id EAAD36B03A1
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 13:12:42 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id jz4so57929269wjb.5
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 10:12:42 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o131si4368663wmd.167.2017.02.14.10.12.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 10:12:41 -0800 (PST)
Date: Tue, 14 Feb 2017 13:12:37 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 05/10] mm, compaction: change migrate_async_suitable()
 to suitable_migration_source()
Message-ID: <20170214181237.GF2450@cmpxchg.org>
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-6-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170210172343.30283-6-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Feb 10, 2017 at 06:23:38PM +0100, Vlastimil Babka wrote:
> Preparation for making the decisions more complex and depending on
> compact_control flags. No functional change.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
