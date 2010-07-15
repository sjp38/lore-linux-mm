Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 49C0F6B02A3
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 14:09:52 -0400 (EDT)
Date: Thu, 15 Jul 2010 14:09:46 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/3] mm: add context argument to shrinker callback
Message-ID: <20100715180946.GA14554@infradead.org>
References: <1279194418-16119-1-git-send-email-david@fromorbit.com>
 <1279194418-16119-2-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1279194418-16119-2-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: xfs@oss.sgi.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 15, 2010 at 09:46:56PM +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> The current shrinker implementation requires the registered callback
> to have global state to work from. This makes it difficult to shrink
> caches that are not global (e.g. per-filesystem caches). Pass the shrinker
> structure to the callback so that users can embed the shrinker structure
> in the context the shrinker needs to operate on and get back to it in the
> callback via container_of().
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>

Looks good,


Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
