Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 5B5736B0044
	for <linux-mm@kvack.org>; Mon,  7 May 2012 14:19:46 -0400 (EDT)
Received: by dadm1 with SMTP id m1so3107066dad.8
        for <linux-mm@kvack.org>; Mon, 07 May 2012 11:19:45 -0700 (PDT)
Date: Mon, 7 May 2012 11:19:41 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 10/10] mm: remove sparsemem allocation details from the
 bootmem allocator
Message-ID: <20120507181941.GF19417@google.com>
References: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
 <1336390672-14421-11-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1336390672-14421-11-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gavin Shan <shangw@linux.vnet.ibm.com>, David Miller <davem@davemloft.net>, Yinghai Lu <yinghai@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 07, 2012 at 01:37:52PM +0200, Johannes Weiner wrote:
> alloc_bootmem_section() derives allocation area constraints from the
> specified sparsemem section.  This is a bit specific for a generic
> memory allocator like bootmem, though, so move it over to sparsemem.
> 
> As __alloc_bootmem_node_nopanic() already retries failed allocations
> with relaxed area constraints, the fallback code in sparsemem.c can be
> removed and the code becomes a bit more compact overall.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

For 03-10

 Acked-by: Tejun Heo <tj@kernel.org>

Thanks for doing this.  While at it, maybe we can clear up the naming
mess there?  I don't hate __s too much but the bootmem allocator
brings it to a whole new level.  :(

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
