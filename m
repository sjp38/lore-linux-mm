Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 148566B0074
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 20:33:01 -0500 (EST)
Date: Mon, 26 Nov 2012 20:32:54 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [Bug 50981] generic_file_aio_read ?: No locking means DATA
 CORRUPTION read and write on same 4096 page  range
Message-ID: <20121127013254.GA25222@thunk.org>
References: <bug-50981-5823@https.bugzilla.kernel.org/>
 <20121126163328.ACEB011FE9C@bugzilla.kernel.org>
 <20121126164555.GL31891@thunk.org>
 <alpine.LNX.2.00.1211261144190.1183@eggly.anvils>
 <20121126201308.GA21050@infradead.org>
 <20121126214937.GA21590@thunk.org>
 <20121126220908.GA20733@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121126220908.GA20733@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, bugzilla-daemon@bugzilla.kernel.org, meetmehiro@gmail.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, Nov 26, 2012 at 05:09:08PM -0500, Christoph Hellwig wrote:
> On Mon, Nov 26, 2012 at 04:49:37PM -0500, Theodore Ts'o wrote:
> > Christoph, can you give some kind of estimate for the overhead that
> > adding this locking in XFS actually costs in practice?
> 
> I don't know any real life measurements, but in terms of implementation
> the over head is:
> 
>  a) taking a the rw_semaphore in shared mode for every buffered read
>  b) taking the slightly slower exclusive rw_semaphore for buffered writes
>     instead of the plain mutex
> 
> On the other hand it significantly simplifies the locking for direct
> I/O and allows parallel direct I/O writers.

I should probably just look at the XFS code, but.... if you're taking
an exclusve lock for buffered writes, won't this impact the
performance of buffered writes happening in parallel on different
CPU's?

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
