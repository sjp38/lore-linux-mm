Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id C8F4A6B0044
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 06:17:47 -0500 (EST)
Date: Thu, 20 Dec 2012 11:17:43 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] ksm: make rmap walks more scalable
Message-ID: <20121220111743.GF10819@suse.de>
References: <alpine.LNX.2.00.1212191735530.25409@eggly.anvils>
 <alpine.LNX.2.00.1212191742440.25409@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1212191742440.25409@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, Petr Holasek <pholasek@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Dec 19, 2012 at 05:44:29PM -0800, Hugh Dickins wrote:
> The rmap walks in ksm.c are like those in rmap.c:
> they can safely be done with anon_vma_lock_read().
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Mel Gorman <mgorman@suse.de>

I'm assuming these are going to go through Andrew's tree as normal for
-mm patches. Andrew?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
