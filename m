Date: Tue, 24 Jun 2008 10:05:57 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [rfc patch 4/4] splice: use do_generic_file_read()
Message-ID: <20080624080557.GK20851@kernel.dk>
References: <20080621154607.154640724@szeredi.hu> <20080621154727.808329488@szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080621154727.808329488@szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 21 2008, Miklos Szeredi wrote:
> From: Miklos Szeredi <mszeredi@suse.cz>
> 
> __generic_file_splice_read() duplicates a lot of stuff common with the
> generic page cache reading.  So reuse that code instead to simplify
> the page cache splice code.
> 
> This also fixes some corner cases which weren't properly handled in
> the splice code because of complexity issues.  In particular it fixes
> a problem when the filesystem (e.g. fuse) invalidates pages during the
> splice operation.
> 
> There might be some slight fall in performance due to the removal of
> the gang lookup for pages.  However I'm not sure if this is
> significant enough to warrant the extra complication.

This makes everything sync, it's a no go. Why don't we look into fixing
the invalidate problem that fuse sees (can you elaborate on that?)?

I tried to do a quick performance test with your patches for comparison
in the cached case, but it crashes immediately in spd_release_page()


-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
