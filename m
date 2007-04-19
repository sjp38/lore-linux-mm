Date: Thu, 19 Apr 2007 09:42:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: dio_get_page() lockdep complaints
Message-Id: <20070419094254.2b273d0c.akpm@linux-foundation.org>
In-Reply-To: <200704191857.42001.vs@namesys.com>
References: <20070419073828.GB20928@kernel.dk>
	<20070419080157.GC20928@kernel.dk>
	<20070419012540.bed394e2.akpm@linux-foundation.org>
	<200704191857.42001.vs@namesys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Vladimir V. Saveliev" <vs@namesys.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, linux-aio@kvack.org, reiserfs-dev@namesys.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Apr 2007 18:57:41 +0400 "Vladimir V. Saveliev" <vs@namesys.com> wrote:

> > It's a bit odd that reiserfs is playing with file contents within
> > file_operations.release(): there could be other files open against that
> > inode.  One would expect this sort of thing to be happening in an
> > inode_operation.  But it's been like that for a long time.
> > 
> 
> reiserfs needs to "pack" file tail when last process which opened a file closes it.
> Can you see more suitable place where that could be performed?

No, you're right - I got my ->release() and ->flush() mixed up.

Possibly one could perform this operation on the final iput(), but I suspect the
locking situation there would be even more complex.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
