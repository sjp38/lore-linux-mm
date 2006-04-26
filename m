Date: Wed, 26 Apr 2006 19:58:13 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Lockless page cache test results
Message-ID: <20060426185813.GA26680@infradead.org>
References: <20060426135310.GB5083@suse.de> <20060426095511.0cc7a3f9.akpm@osdl.org> <20060426174235.GC5002@suse.de> <20060426111054.2b4f1736.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060426111054.2b4f1736.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Jens Axboe <axboe@suse.de>, linux-kernel@vger.kernel.org, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 26, 2006 at 11:10:54AM -0700, Andrew Morton wrote:
> > But boy I wish find_get_pages_contig() was there
> > for that. I think I'd prefer adding that instead of coding that logic in
> > splice, it can get a little tricky.
> 
> I guess it'd make sense - we haven't had a need for such a thing before.
> 
> umm, something like...

XFS would have a use for it, too.  In fact XFS would prefer a
find_or_create_pages-like thing which is the thing splice wants in
the end aswell.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
