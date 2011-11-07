Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id E70DE6B0080
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 10:32:30 -0500 (EST)
Date: Mon, 7 Nov 2011 16:32:20 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mremap: skip page table lookup for non-faulted anonymous
 VMAs
Message-ID: <20111107153220.GD3249@redhat.com>
References: <201111071221.35403.nai.xia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201111071221.35403.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Mon, Nov 07, 2011 at 12:21:35PM +0800, Nai Xia wrote:
> If an anonymous vma has not yet been faulted, move_page_tables() in move_vma()
> is not necessary for it.

I actually thought of adding that (in fact fork has it and it's more
likely to be beneficial for fork than for mremap I suspect), but this
adds a branch to the fast path for a case that shouldn't normally
materialize. So I don't think it's worth adding it as I expect it to
add overhead in average.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
