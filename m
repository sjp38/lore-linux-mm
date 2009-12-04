Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C78396B003D
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 12:16:45 -0500 (EST)
Date: Fri, 4 Dec 2009 09:16:40 -0800
From: Chris Wright <chrisw@redhat.com>
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
Message-ID: <20091204171640.GE19624@x200.localdomain>
References: <20091202125501.GD28697@random.random>
 <20091203134610.586E.A69D9226@jp.fujitsu.com>
 <20091204135938.5886.A69D9226@jp.fujitsu.com>
 <20091204141617.f4c491e7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091204141617.f4c491e7.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki (kamezawa.hiroyu@jp.fujitsu.com) wrote:
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > Windows kernel have zero page thread and it clear the pages in free list
> > periodically. because many windows subsystem prerefer zero filled page.
> > hen, if we use windows guest, zero filled page have plenty mapcount rather
> > than other typical sharing pages, I guess.
> > 
> > So, can we mark as unevictable to zero filled ksm page? 

That's why I mentioned the page of zeroes as the prime example of
something with a high mapcount that shouldn't really ever be evicted.

> Hmm, can't we use ZERO_PAGE we have now ?
> If do so,
>  - no mapcount check
>  - never on LRU
>  - don't have to maintain shared information because ZERO_PAGE itself has
>    copy-on-write nature.

It's a somewhat special case, but wouldn't it be useful to have a generic
method to recognize this kind of sharing since it's a generic issue?

thanks,
-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
