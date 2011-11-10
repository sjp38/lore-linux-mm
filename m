Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 37E846B006E
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 18:37:38 -0500 (EST)
Received: by ywp17 with SMTP id 17so188419ywp.14
        for <linux-mm@kvack.org>; Thu, 10 Nov 2011 15:37:36 -0800 (PST)
Date: Thu, 10 Nov 2011 15:37:32 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Do not stall in synchronous compaction for THP
 allocations
In-Reply-To: <20111110151211.523fa185.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1111101536330.2194@chino.kir.corp.google.com>
References: <20111110100616.GD3083@suse.de> <20111110142202.GE3083@suse.de> <CAEwNFnCRCxrru5rBk7FpypqeL8nD=SY5W3-TaA7Ap5o4CgDSbg@mail.gmail.com> <20111110161331.GG3083@suse.de> <20111110151211.523fa185.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 10 Nov 2011, Andrew Morton wrote:

> > This patch once again prevents sync migration for transparent
> > hugepage allocations as it is preferable to fail a THP allocation
> > than stall.
> 
> Who said?  ;) Presumably some people would prefer to get lots of
> huge pages for their 1000-hour compute job, and waiting a bit to get
> those pages is acceptable.
> 

Indeed.  It seems like the behavior would better be controlled with 
/sys/kernel/mm/transparent_hugepage/defrag which is set aside specifically 
to control defragmentation for transparent hugepages and for that 
synchronous compaction should certainly apply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
