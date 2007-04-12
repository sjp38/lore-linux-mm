Subject: Re: [rfc] rename page_count for lockless pagecache
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070412103340.5564.23286.sendpatchset@linux.site>
References: <20070412103151.5564.16127.sendpatchset@linux.site>
	 <20070412103340.5564.23286.sendpatchset@linux.site>
Content-Type: text/plain
Date: Thu, 12 Apr 2007 19:03:39 +0200
Message-Id: <1176397419.6893.126.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-04-12 at 14:46 +0200, Nick Piggin wrote:
> In order to force an audit of page_count users (which I have already done
> for in-tree users), and to ensure people think about page_count correctly
> in future, I propose this (incomplete, RFC) patch to rename page_count.
> 

My compiler suggests you did a very terse job, but given that its an
RFC... :-)

Anyway, I like it, but I'll leave it out for now.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
