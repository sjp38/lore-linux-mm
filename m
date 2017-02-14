Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C14656B03A6
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 13:15:12 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id v67so47665409wrb.4
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 10:15:12 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 60si1670251wri.305.2017.02.14.10.15.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 10:15:11 -0800 (PST)
Date: Tue, 14 Feb 2017 13:15:00 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 06/10] mm, compaction: add migratetype to
 compact_control
Message-ID: <20170214181500.GG2450@cmpxchg.org>
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-7-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170210172343.30283-7-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Feb 10, 2017 at 06:23:39PM +0100, Vlastimil Babka wrote:
> Preparation patch. We are going to need migratetype at lower layers than
> compact_zone() and compact_finished().
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
