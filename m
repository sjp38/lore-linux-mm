Message-ID: <451BFB84.5070903@oracle.com>
Date: Thu, 28 Sep 2006 12:42:44 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Reply-To: chuck.lever@oracle.com
MIME-Version: 1.0
Subject: Re: Checking page_count(page) in invalidate_complete_page
References: <4518333E.2060101@oracle.com>	<20060925141036.73f1e2b3.akpm@osdl.org>	<45185D7E.6070104@yahoo.com.au>	<451862C5.1010900@oracle.com>	<45186481.1090306@yahoo.com.au>	<45186DC3.7000902@oracle.com>	<451870C6.6050008@yahoo.com.au>	<4518835D.3080702@oracle.com>	<451886FB.50306@yahoo.com.au>	<451BF7BC.1040807@oracle.com>	<20060928093640.14ecb1b1.akpm@osdl.org> <20060928094023.e888d533.akpm@osdl.org>
In-Reply-To: <20060928094023.e888d533.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Trond Myklebust <Trond.Myklebust@netapp.com>, Steve Dickson <steved@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 28 Sep 2006 09:36:40 -0700
> Andrew Morton <akpm@osdl.org> wrote:
> 
>>> I think a call to lru_add_drain_all() belongs in both the 
>>> invalidate_inode_pages() and the invalidate_inode_pages2() path.  Do you 
>>> agree?
>> Yes.
> 
> Or maybe not.  lru_add_drain() will only drain the local CPU's buffer.  If
> the page is sitting in another CPU's buffer, the same problem will occur.
> 
> IOW, you got lucky.

I used lru_add_drain_all(), so it hit all the per-CPU pagevecs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
