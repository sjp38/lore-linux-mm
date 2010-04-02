Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B298E6B01FF
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 05:18:25 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o329ILb9015616
	for <linux-mm@kvack.org>; Fri, 2 Apr 2010 11:18:22 +0200
Received: from pwi7 (pwi7.prod.google.com [10.241.219.7])
	by wpaz24.hot.corp.google.com with ESMTP id o329IKC0006759
	for <linux-mm@kvack.org>; Fri, 2 Apr 2010 02:18:20 -0700
Received: by pwi7 with SMTP id 7so1576464pwi.21
        for <linux-mm@kvack.org>; Fri, 02 Apr 2010 02:18:19 -0700 (PDT)
Date: Fri, 2 Apr 2010 02:18:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 5/5] oom: cleanup oom_badness
In-Reply-To: <20100402094452.07aaffd1.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1004020217400.7493@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004011240370.13247@chino.kir.corp.google.com> <alpine.DEB.2.00.1004011244040.13247@chino.kir.corp.google.com> <20100402094452.07aaffd1.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Apr 2010, KAMEZAWA Hiroyuki wrote:

> > oom_badness() no longer uses its uptime formal, so it can be removed.
> > 
> > Reported-by: Oleg Nesterov <oleg@redhat.com>
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> okay. BTW, only this patch has to depend on mmotm ?
> 

Right, I hope my usage of "-mm" in the subject makes it clear, sorry if it 
was confusing.

> Reviewd-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 

Thanks for your reviews of this patchset!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
