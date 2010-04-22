Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 133E96B01E3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 03:23:32 -0400 (EDT)
Date: Thu, 22 Apr 2010 17:23:19 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable
 task can be found
Message-ID: <20100422072319.GW5683@laptop>
References: <alpine.DEB.2.00.1004061426420.28700@chino.kir.corp.google.com>
 <20100407092050.48c8fc3d.kamezawa.hiroyu@jp.fujitsu.com>
 <20100407205418.FB90.A69D9226@jp.fujitsu.com>
 <alpine.DEB.2.00.1004081036520.25592@chino.kir.corp.google.com>
 <20100421121758.af52f6e0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100421121758.af52f6e0.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 21, 2010 at 12:17:58PM -0700, Andrew Morton wrote:
> 
> fyi, I still consider these patches to be in the "stuck" state.  So we
> need to get them unstuck.
> 
> 
> Hiroyuki (and anyone else): could you please summarise in the briefest
> way possible what your objections are to Daivd's oom-killer changes?
> 
> I'll start: we don't change the kernel ABI.  Ever.  And when we _do_
> change it we don't change it without warning.

How is this turning into such a big issue? It is totally ridiculous.
It is not even a "cleanup".

Just drop the ABI-changing patches, and I think the rest of them looked
OK, didn't they?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
