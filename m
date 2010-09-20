Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 36EF66B0047
	for <linux-mm@kvack.org>; Sun, 19 Sep 2010 22:35:51 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o8K2ZkxG010182
	for <linux-mm@kvack.org>; Sun, 19 Sep 2010 19:35:47 -0700
Received: from pxi1 (pxi1.prod.google.com [10.243.27.1])
	by wpaz21.hot.corp.google.com with ESMTP id o8K2ZjJW019497
	for <linux-mm@kvack.org>; Sun, 19 Sep 2010 19:35:45 -0700
Received: by pxi1 with SMTP id 1so1624311pxi.38
        for <linux-mm@kvack.org>; Sun, 19 Sep 2010 19:35:44 -0700 (PDT)
Date: Sun, 19 Sep 2010 19:35:34 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] fix swapin race condition
In-Reply-To: <20100918131907.GI18596@random.random>
Message-ID: <alpine.LSU.2.00.1009191924110.2779@sister.anvils>
References: <20100903153958.GC16761@random.random> <alpine.LSU.2.00.1009051926330.12092@sister.anvils> <alpine.LSU.2.00.1009151534060.5630@tigran.mtv.corp.google.com> <20100915234237.GR5981@random.random> <alpine.DEB.2.00.1009151703060.7332@tigran.mtv.corp.google.com>
 <20100916210349.GU5981@random.random> <alpine.LSU.2.00.1009161905190.2517@tigran.mtv.corp.google.com> <20100918131907.GI18596@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 18 Sep 2010, Andrea Arcangeli wrote:
> On Thu, Sep 16, 2010 at 07:31:57PM -0700, Hugh Dickins wrote:
> > 
> > Here's what I think can happen: you may shame me by shooting it down
> > immediately, but go ahead!
> 
> Can't shoot it. This definitely helped. My previous scenario only
> involved threads, so I was only thinking at threads...

Thanks a lot for going through it.

> > B ought to have checked that page1's swap was still swap1.
> 
> I suggest adding the explanation to the patch comment.

Absolutely: patch to Linus follows.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
