Date: Wed, 27 Sep 2006 01:25:43 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Checking page_count(page) in invalidate_complete_page
Message-Id: <20060927012543.3c8657c6.akpm@osdl.org>
In-Reply-To: <451A025E.7020008@yahoo.com.au>
References: <4518333E.2060101@oracle.com>
	<20060925141036.73f1e2b3.akpm@osdl.org>
	<45185D7E.6070104@yahoo.com.au>
	<451862C5.1010900@oracle.com>
	<45186481.1090306@yahoo.com.au>
	<45186DC3.7000902@oracle.com>
	<451870C6.6050008@yahoo.com.au>
	<4518835D.3080702@oracle.com>
	<4518C7F1.3050809@yahoo.com.au>
	<4519273C.3000301@oracle.com>
	<451A025E.7020008@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: chuck.lever@oracle.com, Trond Myklebust <Trond.Myklebust@netapp.com>, Steve Dickson <steved@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Sep 2006 14:47:26 +1000
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> truncate_inode_pages will a) throw away everything including dirty 
> pages, and b) probably be fairly
> racy unless the inode's i_size (for normal files) is modified.
> 
> We really want to make an invalidation that works properly for you.
> 
> If you can guarantee that a pagecache page can never get mapped to a 
> user mapping (eg. perhaps for
> directories and symlinks) and also ensure that you don't dirty it via 
> the filesystem, then you don't
> have to worry about it becoming dirty, so we can skip the checks Andrew 
> has added and maybe add a
> WARN_ON(PageDirty()).

None of that is true for when invalidate_inode_pages2() is used by
block-backed direct-io.

We should fix it for that application..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
