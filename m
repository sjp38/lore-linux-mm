Date: Thu, 9 Oct 2008 10:33:58 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 4/8] mm: write_cache_pages type overflow fix
Message-ID: <20081009083358.GA30639@wotan.suse.de>
References: <20081009155039.139856823@suse.de> <20081009174822.516911376@suse.de> <20081009082336.GB6637@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081009082336.GB6637@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 09, 2008 at 04:23:36AM -0400, Christoph Hellwig wrote:
> On Fri, Oct 10, 2008 at 02:50:43AM +1100, npiggin@suse.de wrote:
> > In the range_cont case, range_start is set to index << PAGE_CACHE_SHIFT, but
> > index is a pgoff_t and range_start is loff_t, so we can get truncation of the
> > value on 32-bit platforms. Fix this by adding the standard loff_t cast.
> > 
> > This is a data interity bug (depending on how range_cont is used).
> 
> Aneesh has a patch to kill the range_cont flag, which is queued up for
> 2.6.28.

OK, great. I guess actually this patch out of all of them could go into
2.6.27 and previous stable kernels because it is obviously correct and
could not really cause a regression.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
