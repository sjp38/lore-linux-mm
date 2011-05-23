Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 039296B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 12:23:27 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p4NGNObd027348
	for <linux-mm@kvack.org>; Mon, 23 May 2011 09:23:24 -0700
Received: from pwj9 (pwj9.prod.google.com [10.241.219.73])
	by hpaq1.eem.corp.google.com with ESMTP id p4NGNHSW008587
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 May 2011 09:23:23 -0700
Received: by pwj9 with SMTP id 9so3521385pwj.34
        for <linux-mm@kvack.org>; Mon, 23 May 2011 09:23:17 -0700 (PDT)
Date: Mon, 23 May 2011 09:23:18 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Adding an ugliness in __read_cache_page()?
In-Reply-To: <20110523072705.GA3966@infradead.org>
Message-ID: <alpine.LSU.2.00.1105230919480.4182@sister.anvils>
References: <alpine.LSU.2.00.1105221518180.17400@sister.anvils> <20110523072705.GA3966@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 23 May 2011, Christoph Hellwig wrote:
> On Sun, May 22, 2011 at 03:25:31PM -0700, Hugh Dickins wrote:
> > I find both ways ugly, but no nice alternative: introducing a new method
> > when the known callers are already tied to tmpfs/ramfs seems over the top.
> 
> Calling into shmem directly is the less ugly variant.

Okay, that's good, thanks.

> Long term killing
> that tmpfs abuse would be even better, but I already lost that fight
> when it was initially added.

I'd better match your restraint and not fan the flames now -
I believe we're on opposite sides, or at least orthogonal on that.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
