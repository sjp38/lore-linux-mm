Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id ECD726B0253
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 13:41:42 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so1618172wib.1
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 10:41:42 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h15si3121958wjq.149.2015.07.30.10.41.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jul 2015 10:41:41 -0700 (PDT)
Date: Thu, 30 Jul 2015 13:41:12 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3 3/3] mm: use numa_mem_id() in alloc_pages_node()
Message-ID: <20150730174112.GC15257@cmpxchg.org>
References: <1438274071-22551-1-git-send-email-vbabka@suse.cz>
 <1438274071-22551-3-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438274071-22551-3-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>

On Thu, Jul 30, 2015 at 06:34:31PM +0200, Vlastimil Babka wrote:
> numa_mem_id() is able to handle allocation from CPUs on memory-less nodes,
> so it's a more robust fallback than the currently used numa_node_id().

Won't it fall through to the next closest memory node in the zonelist
anyway? Is this for callers doing NUMA_NO_NODE with __GFP_THISZONE?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
