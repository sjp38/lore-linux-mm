Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 5C3016B0044
	for <linux-mm@kvack.org>; Mon,  7 May 2012 14:07:12 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so8846728pbb.14
        for <linux-mm@kvack.org>; Mon, 07 May 2012 11:07:11 -0700 (PDT)
Date: Mon, 7 May 2012 11:07:06 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 01/10] mm: bootmem: fix checking the bitmap when
 finally freeing bootmem
Message-ID: <20120507180706.GD19417@google.com>
References: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
 <1336390672-14421-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1336390672-14421-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gavin Shan <shangw@linux.vnet.ibm.com>, David Miller <davem@davemloft.net>, Yinghai Lu <yinghai@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 07, 2012 at 01:37:43PM +0200, Johannes Weiner wrote:
> From: Gavin Shan <shangw@linux.vnet.ibm.com>
> 
> When bootmem releases an unaligned chunk of memory at the beginning of
> a node to the page allocator, it iterates from that unaligned PFN but
> checks an aligned word of the page bitmap.  The checked bits do not
> correspond to the PFNs and, as a result, reserved pages can be freed.
> 
> Properly shift the bitmap word so that the lowest bit corresponds to
> the starting PFN before entering the freeing loop.
> 
> This bug has been around since 41546c1 "bootmem: clean up
> free_all_bootmem_core" (2.6.27) without known reports.
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
