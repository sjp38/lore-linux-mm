Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B94C76B004D
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 21:35:03 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n681doqN008069
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 8 Jul 2009 10:39:50 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 78C2745DE54
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 10:39:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 575B145DE4E
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 10:39:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D9261DB8043
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 10:39:50 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E676F1DB803A
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 10:39:49 +0900 (JST)
Date: Wed, 8 Jul 2009 10:38:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/4] get_user_pages READ fault handling special
 cases
Message-Id: <20090708103807.ae17396a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090708090344.aa54a008.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com>
	<20090707165950.7a84145a.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.01.0907070931340.3210@localhost.localdomain>
	<20090708090344.aa54a008.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Jul 2009 09:03:44 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 7 Jul 2009 09:50:19 -0700 (PDT)
> Linus Torvalds <torvalds@linux-foundation.org> wrote:
> > And I think that if we resurrect zero-page, then we should do it with the 
> > modern equivalent of PAGE_RESERVED, namely the "pte_special()" bit. 
> > Anybody who walks page tables had better already handle special PTE 
> > entries (or we could trivially extend them - in case they currently just 
> > look at the vm_flags and decide that the range can have no special pages).
> > 
> Hm, ok. I'll remove pte_zero and use pte_special instead of it.
> 

Can I make a question ?

As far as I know,

 - ZERO PAGE was not accounted as RSS (in 2.6.9 age)
 - ZERO PAGE was accounted as file_rss (until 2.6.24)

Maybe this one is the change.

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=
commitdiff;h=4294621f41a85497019fae64341aa5351a1921b7

Is there a special reason to have to account zero page as file_rss ?
If not, pte_special() solution works well. (I think not necessary..)

This was one reason I added pte_zero().

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
