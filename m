Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3EEEB6B01E3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 03:29:35 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3M7TWuw025789
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 22 Apr 2010 16:29:32 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DE15545DE51
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 16:29:31 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BB0B145DE4F
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 16:29:31 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 993C1E08001
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 16:29:31 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 49409E08002
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 16:29:31 +0900 (JST)
Date: Thu, 22 Apr 2010 16:25:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable
 task can be found
Message-Id: <20100422162536.b904203e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100422072319.GW5683@laptop>
References: <alpine.DEB.2.00.1004061426420.28700@chino.kir.corp.google.com>
	<20100407092050.48c8fc3d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100407205418.FB90.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1004081036520.25592@chino.kir.corp.google.com>
	<20100421121758.af52f6e0.akpm@linux-foundation.org>
	<20100422072319.GW5683@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Apr 2010 17:23:19 +1000
Nick Piggin <npiggin@suse.de> wrote:

> On Wed, Apr 21, 2010 at 12:17:58PM -0700, Andrew Morton wrote:
> > 
> > fyi, I still consider these patches to be in the "stuck" state.  So we
> > need to get them unstuck.
> > 
> > 
> > Hiroyuki (and anyone else): could you please summarise in the briefest
> > way possible what your objections are to Daivd's oom-killer changes?
> > 
> > I'll start: we don't change the kernel ABI.  Ever.  And when we _do_
> > change it we don't change it without warning.
> 
> How is this turning into such a big issue? It is totally ridiculous.
> It is not even a "cleanup".
> 
> Just drop the ABI-changing patches, and I think the rest of them looked
> OK, didn't they?
> 
I agree with you.

-Kame 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
