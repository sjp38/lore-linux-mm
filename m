Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 28B406B0253
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 13:36:23 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so1505624wib.0
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 10:36:22 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id as8si3136543wjc.92.2015.07.30.10.36.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jul 2015 10:36:22 -0700 (PDT)
Date: Thu, 30 Jul 2015 13:35:53 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3 2/3] mm: unify checks in alloc_pages_node() and
 __alloc_pages_node()
Message-ID: <20150730173553.GB15257@cmpxchg.org>
References: <1438274071-22551-1-git-send-email-vbabka@suse.cz>
 <1438274071-22551-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438274071-22551-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org

On Thu, Jul 30, 2015 at 06:34:30PM +0200, Vlastimil Babka wrote:
> Perform the same debug checks in alloc_pages_node() as are done in
> __alloc_pages_node(), by making the former function a wrapper of the latter
> one.
> 
> In addition to better diagnostics in DEBUG_VM builds for situations which
> have been already fatal (e.g. out-of-bounds node id), there are two visible
> changes for potential existing buggy callers of alloc_pages_node():
> 
> - calling alloc_pages_node() with any negative nid (e.g. due to arithmetic
>   overflow) was treated as passing NUMA_NO_NODE and fallback to local node was
>   applied. This will now be fatal.
> - calling alloc_pages_node() with an offline node will now be checked for
>   DEBUG_VM builds. Since it's not fatal if the node has been previously online,
>   and this patch may expose some existing buggy callers, change the VM_BUG_ON
>   in __alloc_pages_node() to VM_WARN_ON.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: David Rientjes <rientjes@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
