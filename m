Message-ID: <45185D2C.8040205@RedHat.com>
Date: Mon, 25 Sep 2006 18:50:20 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
Subject: Re: Checking page_count(page) in invalidate_complete_page
References: <4518333E.2060101@oracle.com> <20060925141036.73f1e2b3.akpm@osdl.org>
In-Reply-To: <20060925141036.73f1e2b3.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: chuck.lever@oracle.com, Trond Myklebust <Trond.Myklebust@netapp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> I think invalidate_inode_pages2() is sufficiently different from (ie:
> stronger than) invalidate_inode_pages() to justify the addition of a new
> invalidate_complete_page2(), which skips the page refcount check.
Removing the page refcount does fix the problem at least the
one we are seeing with NFS not being able to flush its readdir cache..

steved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
