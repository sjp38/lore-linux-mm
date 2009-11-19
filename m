Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1D1AF6B006A
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 02:10:58 -0500 (EST)
Date: Wed, 18 Nov 2009 23:11:07 -0800 (PST)
From: Vincent Li <macli@brc.ubc.ca>
Subject: Re: [PATCH]  [for mmotm-1113] mm: Simplify try_to_unmap_one()
In-Reply-To: <20091119152748.3E37.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911182303530.21547@kernalhack.brc.ubc.ca>
References: <20091119144657.3E34.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.0911182207530.21028@kernalhack.brc.ubc.ca> <20091119152748.3E37.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Vincent Li <macli@brc.ubc.ca>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Thu, 19 Nov 2009, KOSAKI Motohiro wrote:

> > 
> > 
> > On Thu, 19 Nov 2009, KOSAKI Motohiro wrote:
> > 
> > > > 
> > > > Hi KOSAKI,
> > > > 
> > > > Thank you for the comment, I am still little confused with the last 
> > > > sentence.
> > > > 
> > > > On Thu, 19 Nov 2009, KOSAKI Motohiro wrote:
> > > > 
> > > > > 
> > > > > +
> > > > > +	/*
> > > > > +	 * We need mmap_sem locking, Otherwise VM_LOCKED check makes
> > > > > +	 * unstable result and race. Plus, We can't wait here because
> > > > > +	 * we now hold anon_vma->lock or mapping->i_mmap_lock.
> > > > > +	 * If trylock failed, The page remain evictable lru and
> > > > > +	 * retry to more unevictable lru by later vmscan.
> > > >            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ I am having 
> > > > trouble to undestand it. Yeah, I should read more code, but the sentence 
> > > > itself make me confused :).
> > > 
> > > Um, this is wrong.
> > > Probably, It should be
> > > 
> > > 	retry to move unevictable lru later.
> > > 
> > > Do you agree this?
> > 
> > Ah, let's see if I understand you correctly, if trylock failed, the page 
> > remain in evictable lru and later vmscan could retry to move the page to 
> > unevictable lru if the page is actually mlocked? 
> 
> Ah, your sentence is better. can you please change code itself?

You mean I submit the change to last comment sentence? sure, no problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
