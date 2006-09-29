Subject: Re: Checking page_count(page) in invalidate_complete_page
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <451D8371.2070101@oracle.com>
References: <4518333E.2060101@oracle.com>
	 <20060925141036.73f1e2b3.akpm@osdl.org>	<45185D7E.6070104@yahoo.com.au>
	 <451862C5.1010900@oracle.com>	<45186481.1090306@yahoo.com.au>
	 <45186DC3.7000902@oracle.com>	<451870C6.6050008@yahoo.com.au>
	 <4518835D.3080702@oracle.com>	<451886FB.50306@yahoo.com.au>
	 <451BF7BC.1040807@oracle.com>	<20060928093640.14ecb1b1.akpm@osdl.org>
	 <20060928094023.e888d533.akpm@osdl.org>	<451BFB84.5070903@oracle.com>
	 <20060928100306.0b58f3c7.akpm@osdl.org> <451C01C8.7020104@oracle.com>
	 <451C6AAC.1080203@yahoo.com.au>  <451D8371.2070101@oracle.com>
Content-Type: text/plain
Date: Fri, 29 Sep 2006 22:45:24 +0200
Message-Id: <1159562724.13651.39.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: chuck.lever@oracle.com
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, Trond Myklebust <Trond.Myklebust@netapp.com>, Steve Dickson <steved@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2006-09-29 at 16:34 -0400, Chuck Lever wrote:

> One option that hasn't been entertained is to remove the "batched LRU
> add" logic all together.  Just gut lru_cache_add -- it should send
> pages immediately to be added to the LRU list.  This is a bit slower, 
> but it fixes the invalidation problems, and makes the icky 
> lru_add_drain_all() a no-op.

That would bring some larger machines to their knees contending on
zone->lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
