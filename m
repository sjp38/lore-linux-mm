Date: Thu, 25 Oct 2001 19:33:43 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: xmm2 - monitor Linux MM active/inactive lists graphically
Message-ID: <20011025193343.K4795@suse.de>
References: <dnvgh351i1.fsf@magla.zg.iskon.hr> <Pine.LNX.4.31.0110250920270.2184-100000@cesium.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.31.0110250920270.2184-100000@cesium.transmeta.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Zlatko Calusic <zlatko.calusic@iskon.hr>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 25 2001, Linus Torvalds wrote:
> 
> On 25 Oct 2001, Zlatko Calusic wrote:
> >
> > Yes, I definitely have DMA turned ON. All parameters are OK. :)
> 
> I suspect it may just be that "queue_nr_requests"/"batch_count" is
> different in -ac: what happens if you tweak them to the same values?
> 
> (See drivers/block/ll_rw_block.c)
> 
> I think -ac made the queues a bit deeper the regular kernel does 128
> requests and a batch-count of 16, I _think_ -ac does something like "2
> requests per megabyte" and batch_count=32, so if you have 512MB you should
> try with
> 
> 	queue_nr_requests = 1024
> 	batch_count = 32

Right, -ac keeps the elevator flow control and proper queue sizes.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
