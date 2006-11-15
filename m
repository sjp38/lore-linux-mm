Date: Wed, 15 Nov 2006 15:39:52 -0500
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: pagefault in generic_file_buffered_write() causing deadlock
Message-ID: <20061115203929.GE2392@think.oraclecorp.com>
References: <1163606265.7662.8.camel@dyn9047017100.beaverton.ibm.com> <20061115090005.c9ec6db5.akpm@osdl.org> <455B5A7B.6010807@us.ibm.com> <20061115112957.e38539e9.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061115112957.e38539e9.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, linux-mm <linux-mm@kvack.org>, ext4 <linux-ext4@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, Nov 15, 2006 at 11:29:57AM -0800, Andrew Morton wrote:
> Oh well.  If it's a deadlock (this is not clear from your description) then
> please gather backtraces of all affected tasks.
> 
> There is an ab/ba deadlock with journal_start() and lock_page(), iirc. 
> Chris and I had a look at that a while back and collapsed in exhaustion -
> it isn't pretty.  

This should be the page fault/journal lock inversion stuff Nick was
working on.  His patchset had a pretty good description of the problems,
Badari can also dig through the novell/ltc bugzillas for vmmstress.
Should be LTC9358.

Hopefully Nick's patches will address all of this.  sles9 had a partial
solution for the mmap deadlock, I think it was to dirty the inode at a
later time.  For some reason, I thought this workload was passing in
later kernels...

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
