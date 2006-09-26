Message-ID: <4518C7F1.3050809@yahoo.com.au>
Date: Tue, 26 Sep 2006 16:25:53 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Checking page_count(page) in invalidate_complete_page
References: <4518333E.2060101@oracle.com> <20060925141036.73f1e2b3.akpm@osdl.org> <45185D7E.6070104@yahoo.com.au> <451862C5.1010900@oracle.com> <45186481.1090306@yahoo.com.au> <45186DC3.7000902@oracle.com> <451870C6.6050008@yahoo.com.au> <4518835D.3080702@oracle.com>
In-Reply-To: <4518835D.3080702@oracle.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: chuck.lever@oracle.com
Cc: Andrew Morton <akpm@osdl.org>, Trond Myklebust <Trond.Myklebust@netapp.com>, Steve Dickson <steved@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chuck Lever wrote:

> Nick Piggin wrote:
>
>> But they're present on the LRU? That's unusual (I guess NFS doesn't 
>> have a buffer cache for a backing
>> block device).
>
>
> That is correct -- NFS doesn't use the buffer cache.



So that raises another question: how do they get to invalidate_inode_pages2
if they are not part of the buffer or pagecache?
--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
