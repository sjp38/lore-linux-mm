Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E669F6B007B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 18:51:58 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1GNqRIs027064
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 17 Feb 2010 08:52:28 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8904045DE50
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 08:52:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 45D2A45DE4C
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 08:52:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E87F51DB8041
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 08:52:26 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 76A731DB8043
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 08:52:26 +0900 (JST)
Date: Wed, 17 Feb 2010 08:48:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm 8/9 v2] oom: avoid oom killer for lowmem allocations
Message-Id: <20100217084858.fd72ec4f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1002160024370.15201@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002151419260.26927@chino.kir.corp.google.com>
	<20100216085706.c7af93e1.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002151606320.14484@chino.kir.corp.google.com>
	<20100216064402.GC5723@laptop>
	<alpine.DEB.2.00.1002152334260.7470@chino.kir.corp.google.com>
	<20100216075330.GJ5723@laptop>
	<alpine.DEB.2.00.1002160024370.15201@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010 00:25:22 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 16 Feb 2010, Nick Piggin wrote:
> 
> > > I'll add this check to __alloc_pages_may_oom() for the !(gfp_mask & 
> > > __GFP_NOFAIL) path since we're all content with endlessly looping.
> > 
> > Thanks. Yes endlessly looping is far preferable to randomly oopsing
> > or corrupting memory.
> > 
> 
> Here's the new patch for your consideration.
> 

Then, can we take kdump in this endlessly looping situaton ?

panic_on_oom=always + kdump can do that. 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
