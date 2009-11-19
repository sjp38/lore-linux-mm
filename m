Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3426B6B004D
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 01:13:55 -0500 (EST)
Date: Wed, 18 Nov 2009 22:14:04 -0800 (PST)
From: Vincent Li <macli@brc.ubc.ca>
Subject: Re: [PATCH]  [for mmotm-1113] mm: Simplify try_to_unmap_one()
In-Reply-To: <20091119144657.3E34.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911182207530.21028@kernalhack.brc.ubc.ca>
References: <20091119100525.3E2B.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.0911182108260.15866@kernalhack.brc.ubc.ca> <20091119144657.3E34.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Thu, 19 Nov 2009, KOSAKI Motohiro wrote:

> > 
> > Hi KOSAKI,
> > 
> > Thank you for the comment, I am still little confused with the last 
> > sentence.
> > 
> > On Thu, 19 Nov 2009, KOSAKI Motohiro wrote:
> > 
> > > 
> > > +
> > > +	/*
> > > +	 * We need mmap_sem locking, Otherwise VM_LOCKED check makes
> > > +	 * unstable result and race. Plus, We can't wait here because
> > > +	 * we now hold anon_vma->lock or mapping->i_mmap_lock.
> > > +	 * If trylock failed, The page remain evictable lru and
> > > +	 * retry to more unevictable lru by later vmscan.
> >            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ I am having 
> > trouble to undestand it. Yeah, I should read more code, but the sentence 
> > itself make me confused :).
> 
> Um, this is wrong.
> Probably, It should be
> 
> 	retry to move unevictable lru later.
> 
> Do you agree this?

Ah, let's see if I understand you correctly, if trylock failed, the page 
remain in evictable lru and later vmscan could retry to move the page to 
unevictable lru if the page is actually mlocked? 

Vincent

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
