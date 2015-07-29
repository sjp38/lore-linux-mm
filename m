Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id D52616B0257
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 09:31:26 -0400 (EDT)
Received: by wicgb10 with SMTP id gb10so200867988wic.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 06:31:26 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id o3si43816965wjz.169.2015.07.29.06.31.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Jul 2015 06:31:24 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 297DB988D8
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 13:31:23 +0000 (UTC)
Date: Wed, 29 Jul 2015 14:31:21 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC v2 3/4] mm: use numa_mem_id in alloc_pages_node()
Message-ID: <20150729133121.GF19352@techsingularity.net>
References: <1437749126-25867-1-git-send-email-vbabka@suse.cz>
 <1437749126-25867-3-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1437749126-25867-3-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Fri, Jul 24, 2015 at 04:45:25PM +0200, Vlastimil Babka wrote:
> numa_mem_id() is able to handle allocation from CPU's on memory-less nodes,
> so it's a more robust fallback than the currently used numa_node_id().
> 
> Suggested-by: Christoph Lameter <cl@linux.com>
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
