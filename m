Date: Tue, 31 Jul 2007 01:35:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
Message-Id: <20070731013514.146ab1bb.akpm@linux-foundation.org>
In-Reply-To: <20070731082751.GB7316@localdomain>
References: <Pine.LNX.4.64.0707301725280.25686@schroedinger.engr.sgi.com>
	<20070731015647.GC32468@localdomain>
	<Pine.LNX.4.64.0707301858280.26859@schroedinger.engr.sgi.com>
	<20070730192721.eb220a9d.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707301934300.27364@schroedinger.engr.sgi.com>
	<20070730214756.c4211678.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707302156440.30284@schroedinger.engr.sgi.com>
	<20070730221736.ccf67c86.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707302224190.30889@schroedinger.engr.sgi.com>
	<20070730225809.ed0a95ff.akpm@linux-foundation.org>
	<20070731082751.GB7316@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: clameter@sgi.com, linux-mm@kvack.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Tue, 31 Jul 2007 01:27:51 -0700 Ravikiran G Thirumalai <kiran@scalex86.org> wrote:

> >From what I can see with .21 and .22, going into reclaim is a problem rather
> than reclaim efficiency itself. Sure, if unreclaimable pages are not on LRU
> it would be good, but the main problem for my narrow eyes is going into
> reclaim when there are no reclaimable pages, and the fact that benchmark
> works as expected with the fixed arithmetic reinforces that impression.
> 
> What am I missing?

The fact that is there are "no reclaimable pages" then the all_unreclaimable
logic should kick in and fix the problem.

Except zone_reclaim() fails to implement it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
