Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2AA466B004D
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 21:27:20 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n771RRts029145
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 7 Aug 2009 10:27:27 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E17145DE50
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 10:27:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2762745DE4C
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 10:27:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D7251DB803E
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 10:27:27 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A53551DB8038
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 10:27:26 +0900 (JST)
Date: Fri, 7 Aug 2009 10:25:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-Id: <20090807102528.e4af0c21.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4A7AACF1.9040400@redhat.com>
References: <20090805024058.GA8886@localhost>
	<4A79C70C.6010200@redhat.com>
	<9EECC02A4CC333418C00A85D21E89326B651C1FE@azsmsx502.amr.corp.intel.com>
	<4A79D88E.2040005@redhat.com>
	<9EECC02A4CC333418C00A85D21E89326B651C21C@azsmsx502.amr.corp.intel.com>
	<4A7AA0CF.2020700@redhat.com>
	<20090806092516.GA18425@localhost>
	<4A7AA3FF.9070808@redhat.com>
	<20090806093507.GA24669@localhost>
	<4A7AA999.8050309@redhat.com>
	<20090806095905.GA30410@localhost>
	<4A7AACF1.9040400@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, Rik van Riel <riel@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 06 Aug 2009 13:14:09 +0300
Avi Kivity <avi@redhat.com> wrote:

> On 08/06/2009 12:59 PM, Wu Fengguang wrote:
> >> Do we know for a fact that only stack pages suffer, or is it what has
> >> been noticed?
> >>      
> >
> > It shall be the first case: "These pages are nearly all stack pages.",
> > Jeff said.
> >    
> 
> Ok.  I can't explain it.  There's no special treatment for guest stack 
> pages.  The accessed bit should be maintained for them exactly like all 
> other pages.
> 
> Are they kernel-mode stack pages, or user-mode stack pages (the 
> difference being that kernel mode stack pages are accessed through large 
> ptes, whereas user mode stack pages are accessed through normal ptes).
> 


Hmm, finally, memcg's problem ?
just as an experiment, how following works ?

 - memory.limit_in_bytes = 128MB
 - memory.memsw.limit_in_bytes = 160MB

By this, if mamory+swap usage hits 160MB, no swap more. 
But plz take care of OOM.

THanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
