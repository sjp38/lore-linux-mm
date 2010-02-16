Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 62FB26B007E
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 02:04:12 -0500 (EST)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id o1G749Aq025447
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 07:04:09 GMT
Received: from pzk7 (pzk7.prod.google.com [10.243.19.135])
	by spaceape9.eur.corp.google.com with ESMTP id o1G73qXI001535
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 23:04:07 -0800
Received: by pzk7 with SMTP id 7so811827pzk.12
        for <linux-mm@kvack.org>; Mon, 15 Feb 2010 23:03:52 -0800 (PST)
Date: Mon, 15 Feb 2010 23:03:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: add comment about deprecation of __GFP_NOFAIL
In-Reply-To: <20100216102626.5f6f0e11.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002152300580.2745@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com> <alpine.DEB.2.00.1002151419260.26927@chino.kir.corp.google.com> <20100216085706.c7af93e1.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002151606320.14484@chino.kir.corp.google.com>
 <20100216092147.85ef7619.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002151712290.23480@chino.kir.corp.google.com> <20100216102626.5f6f0e11.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010, KAMEZAWA Hiroyuki wrote:

> I hope no 3rd vendor (proprietary) driver uses __GFP_NOFAIL, they tend to
> believe API is trustable and unchanged.
> 

I hope they don't use it with GFP_ATOMIC, either, because it's never been 
respected in that context.  We can easily audit the handful of cases in 
the kernel that use __GFP_NOFAIL (it takes five minutes at the max) and 
prove that none use it with GFP_ATOMIC or GFP_NOFS.  We don't need to add 
multitudes of warnings about using a deprecated flag with ludicrous 
combinations (does anyone really expect GFP_ATOMIC | __GFP_NOFAIL to work 
gracefully)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
