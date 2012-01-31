Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 4D97B6B13F0
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 06:53:25 -0500 (EST)
Date: Tue, 31 Jan 2012 19:42:56 +0800
From: Wu Fengguang <wfg@linux.intel.com>
Subject: Re: [PATCH] fix readahead pipeline break caused by block plug
Message-ID: <20120131114256.GA8796@localhost>
References: <1327996780.21268.42.camel@sli10-conroe>
 <20120131103416.GA1661@localhost>
 <20120131104621.GA27003@infradead.org>
 <20120131105754.GA3867@localhost>
 <20120131113452.GA3235@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120131113452.GA3235@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Shaohua Li <shaohua.li@intel.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Herbert Poetzl <herbert@13thfloor.at>, Eric Dumazet <eric.dumazet@gmail.com>, Vivek Goyal <vgoyal@redhat.com>

On Tue, Jan 31, 2012 at 06:34:52AM -0500, Christoph Hellwig wrote:
> On Tue, Jan 31, 2012 at 06:57:54PM +0800, Wu Fengguang wrote:
> > The problem is, there are a dozen of ->direct_IO callback functions.
> > While there are only two ->direct_IO() callers, one for READ and
> > another for WRITE, which are much easier to deal with.
> 
> So what?  Better do a bit more work now and keep the damn thing
> maintainable.

What if we add a wrapper function for doing

        blk_start_plug(&plug);
        ->direct_IO()
        blk_finish_plug(&plug);

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
