Date: Fri, 13 Apr 2007 18:59:30 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: question on mmap
In-Reply-To: <835465.82854.qm@web43140.mail.sp1.yahoo.com>
Message-ID: <Pine.LNX.4.64.0704131856050.8823@blonde.wat.veritas.com>
References: <835465.82854.qm@web43140.mail.sp1.yahoo.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sameer sameer <sameerchakravarthy@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Apr 2007, sameer sameer wrote:
> 
> I have a question regarding the implementation of
> mmap. I am trying to find out if we the kernel
> actually shares the memory across unrelated processes
> using MAP_SHARED flag for a read only file mapping. 

Yes, it does.

> 
> When the file is mapped with PROT_READ arguement, then
> will there be any difference in memory usage by
> multiple processes if the mapping is done using
> MAP_SHARED instead of MAP_PRIVATE ?

No, no difference.

> 
> Are there any system commands which will let me know
> how to calcuate the memory savings (if there are any)

No such savings.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
