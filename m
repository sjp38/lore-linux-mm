Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 11D866B01F1
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 06:09:54 -0400 (EDT)
Date: Thu, 22 Apr 2010 20:09:44 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable
 task can be found
Message-ID: <20100422100944.GX5683@laptop>
References: <alpine.DEB.2.00.1004061426420.28700@chino.kir.corp.google.com>
 <20100407092050.48c8fc3d.kamezawa.hiroyu@jp.fujitsu.com>
 <20100407205418.FB90.A69D9226@jp.fujitsu.com>
 <alpine.DEB.2.00.1004081036520.25592@chino.kir.corp.google.com>
 <20100421121758.af52f6e0.akpm@linux-foundation.org>
 <20100422072319.GW5683@laptop>
 <20100422162536.b904203e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100422162536.b904203e.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 22, 2010 at 04:25:36PM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 22 Apr 2010 17:23:19 +1000
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > On Wed, Apr 21, 2010 at 12:17:58PM -0700, Andrew Morton wrote:
> > > 
> > > fyi, I still consider these patches to be in the "stuck" state.  So we
> > > need to get them unstuck.
> > > 
> > > 
> > > Hiroyuki (and anyone else): could you please summarise in the briefest
> > > way possible what your objections are to Daivd's oom-killer changes?
> > > 
> > > I'll start: we don't change the kernel ABI.  Ever.  And when we _do_
> > > change it we don't change it without warning.
> > 
> > How is this turning into such a big issue? It is totally ridiculous.
> > It is not even a "cleanup".
> > 
> > Just drop the ABI-changing patches, and I think the rest of them looked
> > OK, didn't they?
> > 
> I agree with you.

Oh actually what happened with the pagefault OOM / panic on oom thing?
We were talking around in circles about that too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
