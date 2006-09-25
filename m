Message-ID: <45185E80.5000202@oracle.com>
Date: Mon, 25 Sep 2006 18:56:00 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Reply-To: chuck.lever@oracle.com
MIME-Version: 1.0
Subject: Re: Checking page_count(page) in invalidate_complete_page
References: <4518333E.2060101@oracle.com> <20060925141036.73f1e2b3.akpm@osdl.org>
In-Reply-To: <20060925141036.73f1e2b3.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, Steve Dickson <steved@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> I think invalidate_inode_pages2() is sufficiently different from (ie:
> stronger than) invalidate_inode_pages() to justify the addition of a new
> invalidate_complete_page2(), which skips the page refcount check.

Almost all of invalidate_complete_page() is the same in both cases.  How 
about using a boolean switch to determine whether the page_count is 
honored or not?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
