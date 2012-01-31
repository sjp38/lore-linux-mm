Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id D57BC6B13F0
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 07:30:46 -0500 (EST)
Date: Tue, 31 Jan 2012 20:20:39 +0800
From: Wu Fengguang <wfg@linux.intel.com>
Subject: Re: [PATCH] fix readahead pipeline break caused by block plug
Message-ID: <20120131122039.GA12706@localhost>
References: <1327996780.21268.42.camel@sli10-conroe>
 <20120131103416.GA1661@localhost>
 <20120131104621.GA27003@infradead.org>
 <20120131105754.GA3867@localhost>
 <20120131113452.GA3235@infradead.org>
 <20120131114256.GA8796@localhost>
 <20120131115716.GA19829@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120131115716.GA19829@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Shaohua Li <shaohua.li@intel.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Herbert Poetzl <herbert@13thfloor.at>, Eric Dumazet <eric.dumazet@gmail.com>, Vivek Goyal <vgoyal@redhat.com>

On Tue, Jan 31, 2012 at 06:57:16AM -0500, Christoph Hellwig wrote:
> On Tue, Jan 31, 2012 at 07:42:56PM +0800, Wu Fengguang wrote:
> > > So what?  Better do a bit more work now and keep the damn thing
> > > maintainable.
> > 
> > What if we add a wrapper function for doing
> > 
> >         blk_start_plug(&plug);
> >         ->direct_IO()
> >         blk_finish_plug(&plug);
> 
> No.  Just put it into __blockdev_direct_IO - a quick 2 minute audit of
> the kernel source shows that is in fact the only ->direct_IO instance
> which ever submits block I/O anyway.

Right, so nice point!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
