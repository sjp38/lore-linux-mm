Subject: Re: [PATCH 00/16] concurrent pagecache (against 2.6.19-rt)
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0612111100300.2253@schroedinger.engr.sgi.com>
References: <20061207161800.426936000@chello.nl>
	 <Pine.LNX.4.64.0612111100300.2253@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 11 Dec 2006 20:24:16 +0100
Message-Id: <1165865056.32332.60.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Mon, 2006-12-11 at 11:03 -0800, Christoph Lameter wrote:
> On Thu, 7 Dec 2006, Peter Zijlstra wrote:
> 
> > Based on Nick's lockless (read-side) pagecache patches (included in the series)
> > here an attempt to make the write side concurrent.
> 
> On first glance it looks quite interesting and very innovative. Removing 
> the tree_lock completely also reduces cache line usage. The page struct 
> cacheline is already references in most contexts.

Thanks, I'm just curious how bouncy the fine grained radix tree locks
will be. 

> > Comment away ;-)
> 
> Could you post Nick's patches from your email addres and add a From Nick 
> line in them? Its a bit confusing to have a patchset with different 
> originating email addresses. Or does this come about by the evil header 
> mangling of the list processor? Maybe you need to use >From ??

Nah that was on purpose, you can grab the patches from here:

http://programming.kicks-ass.net/kernel-patches/concurrent-pagecache-rt/

if you care, or I can post them again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
