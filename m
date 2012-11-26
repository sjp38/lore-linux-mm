Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 2D43A6B0071
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 16:49:44 -0500 (EST)
Date: Mon, 26 Nov 2012 16:49:37 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [Bug 50981] generic_file_aio_read ?: No locking means DATA
 CORRUPTION read and write on same 4096 page  range
Message-ID: <20121126214937.GA21590@thunk.org>
References: <bug-50981-5823@https.bugzilla.kernel.org/>
 <20121126163328.ACEB011FE9C@bugzilla.kernel.org>
 <20121126164555.GL31891@thunk.org>
 <alpine.LNX.2.00.1211261144190.1183@eggly.anvils>
 <20121126201308.GA21050@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121126201308.GA21050@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, bugzilla-daemon@bugzilla.kernel.org, meetmehiro@gmail.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, Nov 26, 2012 at 03:13:08PM -0500, Christoph Hellwig wrote:
> On Mon, Nov 26, 2012 at 12:05:57PM -0800, Hugh Dickins wrote:
> > Gosh, that's a very sudden new consensus.  The consensus over the past
> > ten or twenty years has been that the Linux kernel enforce locking for
> > consistent atomic writes, but skip that overhead on reads - hasn't it?
> 
> I'm not sure there was much of a consensus ever.  We XFS people always
> ttried to push everyone down the strict rule, but there was enough
> pushback that it didn't actually happen.

Christoph, can you give some kind of estimate for the overhead that
adding this locking in XFS actually costs in practice?  And does XFS
provide any kind of consistency guarantees if the reads/write overlap
spans multiple pages?  I assume the answer to that is no, correct?

Thanks,

                                              - Ted 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
