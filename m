Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD8FD6B0389
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 05:53:57 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id y7so35618852wrc.7
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 02:53:57 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id z63si5036130wmh.110.2017.02.13.02.53.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 02:53:56 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 797AF1C235C
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 10:53:56 +0000 (GMT)
Date: Mon, 13 Feb 2017 10:53:55 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2 06/10] mm, compaction: add migratetype to
 compact_control
Message-ID: <20170213105355.v2n4zk3yaa3swjcz@techsingularity.net>
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-7-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170210172343.30283-7-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Feb 10, 2017 at 06:23:39PM +0100, Vlastimil Babka wrote:
> Preparation patch. We are going to need migratetype at lower layers than
> compact_zone() and compact_finished().
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
