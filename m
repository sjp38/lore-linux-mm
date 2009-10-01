Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7D06B00A1
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 15:49:28 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id n91KZqv1019474
	for <linux-mm@kvack.org>; Thu, 1 Oct 2009 13:35:52 -0700
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by wpaz13.hot.corp.google.com with ESMTP id n91KZ5QP014904
	for <linux-mm@kvack.org>; Thu, 1 Oct 2009 13:35:50 -0700
Received: by pzk37 with SMTP id 37so557577pzk.10
        for <linux-mm@kvack.org>; Thu, 01 Oct 2009 13:35:49 -0700 (PDT)
Date: Thu, 1 Oct 2009 13:35:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 01/31] mm: serialize access to min_free_kbytes
In-Reply-To: <1254405871-15687-1-git-send-email-sjayaraman@suse.de>
Message-ID: <alpine.DEB.1.00.0910011330430.27559@chino.kir.corp.google.com>
References: <1254405871-15687-1-git-send-email-sjayaraman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Suresh Jayaraman <sjayaraman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Thu, 1 Oct 2009, Suresh Jayaraman wrote:

> From: Peter Zijlstra <a.p.zijlstra@chello.nl> 
> 
> There is a small race between the procfs caller and the memory hotplug caller
> of setup_per_zone_wmarks(). Not a big deal, but the next patch will add yet
> another caller. Time to close the gap.
> 

By "next patch," you mean "mm: emegency pool" (patch 08/31)?

If so, can't you eliminate var_free_mutex entirely from that patch and 
take min_free_lock in adjust_memalloc_reserve() instead?

 [ __adjust_memalloc_reserve() would call __setup_per_zone_wmarks()
   under lock instead, now. ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
