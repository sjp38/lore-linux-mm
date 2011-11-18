Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 650876B0069
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 08:37:07 -0500 (EST)
Date: Fri, 18 Nov 2011 13:37:00 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm,x86: remove debug_pagealloc_enabled
Message-ID: <20111118133700.GB20840@suse.de>
References: <1321458232-6823-1-git-send-email-sgruszka@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1321458232-6823-1-git-send-email-sgruszka@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Nov 16, 2011 at 04:43:52PM +0100, Stanislaw Gruszka wrote:
> When (no)bootmem finish operation, it pass pages to buddy allocator.
> Since debug_pagealloc_enabled is not set, we will do not protect pages,
> what is not what we want with CONFIG_DEBUG_PAGEALLOC=y.
> 
> To fix remove debug_pagealloc_enabled. That variable was introduced by
> commit 12d6f21e "x86: do not PSE on CONFIG_DEBUG_PAGEALLOC=y" to get
> more CPA (change page attribude) code testing. But currently we have
> CONFIG_CPA_DEBUG, which test CPA.
> 
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>

If no one objects to the impact on CPA testing, I see no problem with
this. I would assume that many bugs related to CPA would be rattled out
by now

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
