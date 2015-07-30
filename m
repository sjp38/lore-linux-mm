Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 747F06B0253
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 13:59:50 -0400 (EDT)
Received: by qgii95 with SMTP id i95so29609351qgi.2
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 10:59:50 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id n33si2234713qkh.21.2015.07.30.10.59.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 10:59:49 -0700 (PDT)
Date: Thu, 30 Jul 2015 12:59:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 3/3] mm: use numa_mem_id() in alloc_pages_node()
In-Reply-To: <1438274071-22551-3-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.11.1507301259230.5521@east.gentwo.org>
References: <1438274071-22551-1-git-send-email-vbabka@suse.cz> <1438274071-22551-3-git-send-email-vbabka@suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>

On Thu, 30 Jul 2015, Vlastimil Babka wrote:

> numa_mem_id() is able to handle allocation from CPUs on memory-less nodes,
> so it's a more robust fallback than the currently used numa_node_id().
>
> Suggested-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: Mel Gorman <mgorman@techsingularity.net>

You can add my ack too if it helps.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
