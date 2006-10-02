Date: Mon, 2 Oct 2006 09:57:27 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Checking page_count(page) in invalidate_complete_page
Message-Id: <20061002095727.05cd052f.akpm@osdl.org>
In-Reply-To: <1159795522.6143.7.camel@lade.trondhjem.org>
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
	<20060929152951.0b763f6a.akpm@osdl.org>
	<451F425F.8030609@oracle.com>
	<4520FFB6.3040801@RedHat.com>
	<1159795522.6143.7.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Steve Dickson <SteveD@redhat.com>, chuck.lever@oracle.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 02 Oct 2006 09:25:22 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2006-10-02 at 08:01 -0400, Steve Dickson wrote:
> > Question: Maybe I missed this... but what is NFS suppose to do
> > when invalidate_inode_pages2() fails on non-file inodes? Noting
> > it with as metric as Chuck suggested is a good way to
> > detect  its happening, but does it make sense for NFS to keep
> > calling invalidate_inode_pages2() until it does not fail when
> > trying to flush the readdir cache?
> 
> Definitely not. There is not much we can do at the filesystem level if
> the VM fails, and that is why we haven't bothered checking the return
> value previously.
> 

Please add a printk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
