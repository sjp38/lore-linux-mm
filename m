Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2E8836B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 16:10:13 -0400 (EDT)
Date: Wed, 15 Sep 2010 22:10:02 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH] fix rmap walk during fork
Message-ID: <20100915201002.GD15987@redhat.com>
References: <20100915171657.GP5981@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100915171657.GP5981@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 15, 2010 at 07:16:57PM +0200, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> The below bug in fork lead to the rmap walk finding the parent huge-pmd twice
> instead of just one, because the anon_vma_chain objects of the child vma still
> point to the vma->vm_mm of the parent. The below patch fixes it by making the
> rmap walk accurate during fork. It's not a big deal normally but it
> worth being accurate considering the cost is the same.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Johannes Weiner <jweiner@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
