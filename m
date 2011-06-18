Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 7810F6B004A
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 21:52:57 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p5I1qsQP030654
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 18:52:55 -0700
Received: from pvc12 (pvc12.prod.google.com [10.241.209.140])
	by kpbe15.cbf.corp.google.com with ESMTP id p5I1qjhU029887
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 18:52:53 -0700
Received: by pvc12 with SMTP id 12so2867968pvc.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2011 18:52:45 -0700 (PDT)
Date: Fri, 17 Jun 2011 18:52:36 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/12] radix_tree: exceptional entries and indices
In-Reply-To: <20110617171228.4c85fd38.rdunlap@xenotime.net>
Message-ID: <alpine.LSU.2.00.1106171845480.20321@sister.anvils>
References: <alpine.LSU.2.00.1106140327550.29206@sister.anvils> <alpine.LSU.2.00.1106140341070.29206@sister.anvils> <20110617163854.49225203.akpm@linux-foundation.org> <20110617170742.282a1bd6.rdunlap@xenotime.net>
 <20110617171228.4c85fd38.rdunlap@xenotime.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: akpm <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 17 Jun 2011, Randy Dunlap wrote:
> > 
> > And regardless of the patch path that is taken, update test(s) if
> > applicable.

Thanks for the links, Randy, I hadn't thought of those at all.

> > I thought that someone from Red Hat had a kernel loadable
> > module for testing radix-tree -- or maybe that was for rbtree (?) --
> > but I can't find that just now.
> 
> http://people.redhat.com/jmoyer/radix-tree/

This one just tests that radix_tree_preload() goes deep enough:
not affected by the little change I've made.

> > And one Andrew Morton has a userspace radix tree test harness at
> > http://userweb.kernel.org/~akpm/stuff/rtth.tar.gz

This should still be as relevant as it was before, but I notice its
radix_tree.c is almost identical to the source currently in the kernel
tree, so I ought at the least to keep it in synch.

Whether there's anything suitable for testing here in the changes that
I've made, I'll have to look into later.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
