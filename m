Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 18BD26B004D
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 00:49:56 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAJ5nrio022147
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 19 Nov 2009 14:49:54 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BFB9645DE52
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 14:49:53 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E07145DE3E
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 14:49:53 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7EC74E1800C
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 14:49:53 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2EE4FE18009
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 14:49:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH]  [for mmotm-1113] mm: Simplify try_to_unmap_one()
In-Reply-To: <alpine.DEB.2.00.0911182108260.15866@kernalhack.brc.ubc.ca>
References: <20091119100525.3E2B.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.0911182108260.15866@kernalhack.brc.ubc.ca>
Message-Id: <20091119144657.3E34.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 19 Nov 2009 14:49:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> 
> Hi KOSAKI,
> 
> Thank you for the comment, I am still little confused with the last 
> sentence.
> 
> On Thu, 19 Nov 2009, KOSAKI Motohiro wrote:
> 
> > 
> > +
> > +	/*
> > +	 * We need mmap_sem locking, Otherwise VM_LOCKED check makes
> > +	 * unstable result and race. Plus, We can't wait here because
> > +	 * we now hold anon_vma->lock or mapping->i_mmap_lock.
> > +	 * If trylock failed, The page remain evictable lru and
> > +	 * retry to more unevictable lru by later vmscan.
>            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ I am having 
> trouble to undestand it. Yeah, I should read more code, but the sentence 
> itself make me confused :).

Um, this is wrong.
Probably, It should be

	retry to move unevictable lru later.

Do you agree this?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
