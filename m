Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 018D76B01CD
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 00:18:49 -0400 (EDT)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o5H4Ik7W018120
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:18:46 -0700
Received: from pvg7 (pvg7.prod.google.com [10.241.210.135])
	by kpbe18.cbf.corp.google.com with ESMTP id o5H4IjU4001388
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:18:45 -0700
Received: by pvg7 with SMTP id 7so237343pvg.17
        for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:18:45 -0700 (PDT)
Date: Wed, 16 Jun 2010 21:18:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 6/9] oom: unify CAP_SYS_RAWIO check into other superuser
 check
In-Reply-To: <20100617104756.FB8F.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006162118160.14101@chino.kir.corp.google.com>
References: <20100617104311.FB7A.A69D9226@jp.fujitsu.com> <20100617104756.FB8F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Jun 2010, KOSAKI Motohiro wrote:

> 
> Now, CAP_SYS_RAWIO check is very strange. if the user have both
> CAP_SYS_ADMIN and CAP_SYS_RAWIO, points will makes 1/16.
> 
> Superuser's 1/4 bonus worthness is quite a bit dubious, but
> considerable. However 1/16 is obviously insane.
> 

This is already obsoleted by the heuristic rewrite that is already under 
review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
