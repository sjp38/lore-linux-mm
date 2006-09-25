Date: Mon, 25 Sep 2006 16:02:00 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Checking page_count(page) in invalidate_complete_page
Message-Id: <20060925160200.4c234f98.akpm@osdl.org>
In-Reply-To: <45185AF3.7030606@oracle.com>
References: <4518333E.2060101@oracle.com>
	<20060925141036.73f1e2b3.akpm@osdl.org>
	<45185AF3.7030606@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: chuck.lever@oracle.com
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, Steve Dickson <steved@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2006 18:40:51 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> invalidate_inode_pages2 appears to wait for locked pages, while 
> invalidate_inode_pages skips them.

That won't help here: vmscan takes a ref on the page prior
to trying to lock it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
