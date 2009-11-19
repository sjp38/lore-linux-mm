Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 105686B004D
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 01:28:43 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAJ6SfKi017691
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 19 Nov 2009 15:28:41 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 839C845DE4D
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 15:28:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5883345DE4F
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 15:28:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C6451DB8042
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 15:28:41 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BDAF31DB803E
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 15:28:40 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH]  [for mmotm-1113] mm: Simplify try_to_unmap_one()
In-Reply-To: <alpine.DEB.2.00.0911182207530.21028@kernalhack.brc.ubc.ca>
References: <20091119144657.3E34.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.0911182207530.21028@kernalhack.brc.ubc.ca>
Message-Id: <20091119152748.3E37.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 19 Nov 2009 15:28:40 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> 
> 
> On Thu, 19 Nov 2009, KOSAKI Motohiro wrote:
> 
> > > 
> > > Hi KOSAKI,
> > > 
> > > Thank you for the comment, I am still little confused with the last 
> > > sentence.
> > > 
> > > On Thu, 19 Nov 2009, KOSAKI Motohiro wrote:
> > > 
> > > > 
> > > > +
> > > > +	/*
> > > > +	 * We need mmap_sem locking, Otherwise VM_LOCKED check makes
> > > > +	 * unstable result and race. Plus, We can't wait here because
> > > > +	 * we now hold anon_vma->lock or mapping->i_mmap_lock.
> > > > +	 * If trylock failed, The page remain evictable lru and
> > > > +	 * retry to more unevictable lru by later vmscan.
> > >            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ I am having 
> > > trouble to undestand it. Yeah, I should read more code, but the sentence 
> > > itself make me confused :).
> > 
> > Um, this is wrong.
> > Probably, It should be
> > 
> > 	retry to move unevictable lru later.
> > 
> > Do you agree this?
> 
> Ah, let's see if I understand you correctly, if trylock failed, the page 
> remain in evictable lru and later vmscan could retry to move the page to 
> unevictable lru if the page is actually mlocked? 

Ah, your sentence is better. can you please change code itself?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
