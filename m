Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 1E9BD6B0044
	for <linux-mm@kvack.org>; Mon,  7 May 2012 14:08:33 -0400 (EDT)
Received: by dadm1 with SMTP id m1so3090251dad.8
        for <linux-mm@kvack.org>; Mon, 07 May 2012 11:08:32 -0700 (PDT)
Date: Mon, 7 May 2012 11:08:28 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 02/10] mm: bootmem: remove redundant offset check when
 finally freeing bootmem
Message-ID: <20120507180828.GE19417@google.com>
References: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
 <1336390672-14421-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1336390672-14421-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gavin Shan <shangw@linux.vnet.ibm.com>, David Miller <davem@davemloft.net>, Yinghai Lu <yinghai@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 07, 2012 at 01:37:44PM +0200, Johannes Weiner wrote:
> When bootmem releases an unaligned BITS_PER_LONG pages chunk of memory
> to the page allocator, it checks the bitmap if there are still
> unreserved pages in the chunk (set bits), but also if the offset in
> the chunk indicates BITS_PER_LONG loop iterations already.
> 
> But since the consulted bitmap is only a one-word-excerpt of the full
> per-node bitmap, there can not be more than BITS_PER_LONG bits set in
> it.  The additional offset check is unnecessary.
> 
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
