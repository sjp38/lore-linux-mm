Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B82A56B01AC
	for <linux-mm@kvack.org>; Sun,  4 Jul 2010 18:08:13 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o64M89Ae013687
	for <linux-mm@kvack.org>; Sun, 4 Jul 2010 15:08:10 -0700
Received: from pxi6 (pxi6.prod.google.com [10.243.27.6])
	by wpaz33.hot.corp.google.com with ESMTP id o64M87sX026496
	for <linux-mm@kvack.org>; Sun, 4 Jul 2010 15:08:08 -0700
Received: by pxi6 with SMTP id 6so168512pxi.15
        for <linux-mm@kvack.org>; Sun, 04 Jul 2010 15:08:07 -0700 (PDT)
Date: Sun, 4 Jul 2010 15:08:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 07/18] oom: filter tasks not sharing the same cpuset
In-Reply-To: <20100702153508.fda82eb9.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1007041506380.25616@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006081149320.18848@chino.kir.corp.google.com> <20100608122740.8f045c78.akpm@linux-foundation.org> <20100613201257.6199.A69D9226@jp.fujitsu.com> <20100702153508.fda82eb9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Jul 2010, Andrew Morton wrote:

> So where do we go from here?  I have about 12,000 oom-killer related
> emails saved up in my todo folder, ready for me to read next time I
> have an oom-killer session.
> 

I'll be proposing my second revision of the badness heuristic rewrite in 
the next couple of days.  That said, I don't know of any other outstanding 
patches that haven't yet been merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
