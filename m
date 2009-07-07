Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 853376B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 04:36:52 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n679KDOU003343
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 7 Jul 2009 18:20:13 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 55AEB45DE50
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 18:20:13 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3871C45DD72
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 18:20:13 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C7131DB803E
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 18:20:13 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B221BE08004
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 18:20:12 +0900 (JST)
Date: Tue, 7 Jul 2009 18:18:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/4] ZERO PAGE again v2
Message-Id: <20090707181829.10d48272.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4A530FD4.7060606@redhat.com>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com>
	<20090707084750.GX2714@wotan.suse.de>
	<4A530FD4.7060606@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 07 Jul 2009 12:05:24 +0300
Avi Kivity <avi@redhat.com> wrote:

> On 07/07/2009 11:47 AM, Nick Piggin wrote:
> >> Any comments are welcome.
> >>      
> >
> > Can we just try to wean them off it? Using zero page for huge sparse
> > matricies is probably not ideal anyway because it needs to still be
> > faulted in and it occupies TLB space. They might see better performance
> > by using a better algorithm.
> >    
> 
> For kvm live migration, I've thought of extending mincore() to report if 
> a page will be read as zeros.
> 
BTW, ksm can scale enough to combine all pages which just includes zero ?
No heavy cache ping-pong without zero-page ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
