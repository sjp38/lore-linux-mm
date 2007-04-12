Date: Fri, 13 Apr 2007 01:27:10 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] rename page_count for lockless pagecache
Message-ID: <20070412232710.GB23523@wotan.suse.de>
References: <20070412103151.5564.16127.sendpatchset@linux.site> <20070412103340.5564.23286.sendpatchset@linux.site> <1176397419.6893.126.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1176397419.6893.126.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 12, 2007 at 07:03:39PM +0200, Peter Zijlstra wrote:
> On Thu, 2007-04-12 at 14:46 +0200, Nick Piggin wrote:
> > In order to force an audit of page_count users (which I have already done
> > for in-tree users), and to ensure people think about page_count correctly
> > in future, I propose this (incomplete, RFC) patch to rename page_count.
> > 
> 
> My compiler suggests you did a very terse job, but given that its an
> RFC... :-)

Yeah, just mm/, to see how it looks.

I have no problem converting the whole tree (there isn't much left),
but the question is whether out of tree drivers use it.

I guess if they do use it, then they need to be checked anyway, so
there isn't really a way we can provide interim compatibility.

> 
> Anyway, I like it, but I'll leave it out for now.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
