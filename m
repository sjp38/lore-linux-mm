Date: Fri, 29 Sep 2006 15:29:51 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Checking page_count(page) in invalidate_complete_page
Message-Id: <20060929152951.0b763f6a.akpm@osdl.org>
In-Reply-To: <451D94A7.9060905@oracle.com>
References: <4518333E.2060101@oracle.com>
	<20060925141036.73f1e2b3.akpm@osdl.org>
	<45185D7E.6070104@yahoo.com.au>
	<451862C5.1010900@oracle.com>
	<45186481.1090306@yahoo.com.au>
	<45186DC3.7000902@oracle.com>
	<451870C6.6050008@yahoo.com.au>
	<4518835D.3080702@oracle.com>
	<451886FB.50306@yahoo.com.au>
	<451BF7BC.1040807@oracle.com>
	<20060928093640.14ecb1b1.akpm@osdl.org>
	<20060928094023.e888d533.akpm@osdl.org>
	<451BFB84.5070903@oracle.com>
	<20060928100306.0b58f3c7.akpm@osdl.org>
	<451C01C8.7020104@oracle.com>
	<451C6AAC.1080203@yahoo.com.au>
	<451D8371.2070101@oracle.com>
	<1159562724.13651.39.camel@lappy>
	<451D89E7.7020307@oracle.com>
	<1159564637.13651.44.camel@lappy>
	<20060929144421.48f9f1bd.akpm@osdl.org>
	<451D94A7.9060905@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: chuck.lever@oracle.com
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, Trond Myklebust <Trond.Myklebust@netapp.com>, Steve Dickson <steved@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 29 Sep 2006 17:48:23 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> Andrew Morton wrote:
> > buggerit, let's do this.  It'll fix NFS, yes?
> 
> It looks right to me.

s/right/less incorrect/ ;)

Please double-check that it passes testing.

>  I'll discuss a patch with Trond that adds a 
> warning in nfs_revalidate_mapping() and perhaps a performance counter to 
> see how many times we hit this in practice.

Yes, please do carefully check the invalidate_inode_pages2() return value:
we've had ongoing subtle problem with that code and we really do want the
early warning which an explicit check+printk will give us.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
