Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 586006B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 16:07:50 -0400 (EDT)
Date: Wed, 15 Sep 2010 22:07:31 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH] unlink_anon_vmas in __split_vma in case of error
Message-ID: <20100915200731.GC15987@redhat.com>
References: <20100915171816.GQ5981@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100915171816.GQ5981@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Marcelo Tosatti <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 15, 2010 at 07:18:16PM +0200, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> If __split_vma fails because of an out of memory condition the
> anon_vma_chain isn't teardown and freed potentially leading to rmap
> walks accessing freed vma information plus there's a memleak.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Johannes Weiner <jweiner@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
