Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 965F56B0044
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 16:39:13 -0400 (EDT)
Message-ID: <50942F67.70502@redhat.com>
Date: Fri, 02 Nov 2012 16:39:03 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 5/6] mm: use vm_unmapped_area() on x86_64 architecture
References: <1351679605-4816-1-git-send-email-walken@google.com> <1351679605-4816-6-git-send-email-walken@google.com>
In-Reply-To: <1351679605-4816-6-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On 10/31/2012 06:33 AM, Michel Lespinasse wrote:
> Signed-off-by: Michel Lespinasse <walken@google.com>

The patch could use a changelog.

> +	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
> +	info.length = len;
> +	info.low_limit = 0;  // XXX could be PAGE_SIZE ???

Indeed.

Everything else in the patch looks good to me.

> +	info.high_limit = mm->mmap_base;
> +	info.align_mask = filp ? get_align_mask() : 0;
> +	info.align_offset = 0;
> +	addr = vm_unmapped_area(&info);
> +	if (!(addr & ~PAGE_MASK))
> +		return addr;
> +	VM_BUG_ON(addr != -ENOMEM);



-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
