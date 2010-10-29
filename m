Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 53F1D6B0103
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 22:50:59 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9T2oufR016047
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 29 Oct 2010 11:50:57 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4474F45DE6E
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 11:50:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 112A845DE6F
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 11:50:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F40C61DB8037
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 11:50:55 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C2B71DB803E
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 11:50:55 +0900 (JST)
Date: Fri, 29 Oct 2010 11:45:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: don't flush TLB when propagate PTE access bit to
 struct page.
Message-Id: <20101029114529.4d3a8b9c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTikdE---MJ-LSwNHEniCphvwu0T2apkWzGsRQ8i=@mail.gmail.com>
References: <1288200090-23554-1-git-send-email-yinghan@google.com>
	<4CC869F5.2070405@redhat.com>
	<AANLkTikL+v6uzkXg-7J2FGVz-7kc0Myw_cO5s_wYfHHm@mail.gmail.com>
	<AANLkTimLBO7mJugVXH0S=QSnwQ+NDcz3zxmcHmPRjngd@mail.gmail.com>
	<alpine.LSU.2.00.1010271144540.5039@tigran.mtv.corp.google.com>
	<AANLkTim9NBXrAWkMW7C5C6=1sh52OJm=u5HT7ShyC7hv@mail.gmail.com>
	<20101028091158.4de545e9.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikdE---MJ-LSwNHEniCphvwu0T2apkWzGsRQ8i=@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ken Chen <kenchen@google.com>
Cc: Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 28 Oct 2010 18:30:23 -0700
Ken Chen <kenchen@google.com> wrote:

> On Wed, Oct 27, 2010 at 5:11 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > I'd like to vote for batching.
> 
> Batch mode isn't going to add much value because the effect of
> accessed bit is already deferred.  There are two outcome: (1) the tlb
> mapping is already flushed due to capacity conflict or (2) process
> context'ed out.  You would want to transfer accessed bit from pte to
> page table, but flushing TLB on a already deferred operation seems not
> that useful.
> 
Hmm. Without flushing anywhere in memory reclaim path, a process which
cause page fault and enter vmscan will not see his own recent access bit on
pages in LRU ?

I think it should be flushed at least once..

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
