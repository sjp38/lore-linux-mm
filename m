Date: Fri, 26 Oct 2001 16:39:58 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: xmm2 - monitor Linux MM active/inactive lists graphically
Message-ID: <20011026163958.C3324@suse.de>
References: <Pine.LNX.4.31.0110250920270.2184-100000@cesium.transmeta.com> <dnr8rqu30x.fsf@magla.zg.iskon.hr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dnr8rqu30x.fsf@magla.zg.iskon.hr>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko.calusic@iskon.hr>
Cc: Linus Torvalds <torvalds@transmeta.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 26 2001, Zlatko Calusic wrote:
> Linus Torvalds <torvalds@transmeta.com> writes:
> 
> > On 25 Oct 2001, Zlatko Calusic wrote:
> > >
> > > Yes, I definitely have DMA turned ON. All parameters are OK. :)
> > 
> > I suspect it may just be that "queue_nr_requests"/"batch_count" is
> > different in -ac: what happens if you tweak them to the same values?
> > 
> 
> Next test:
> 
> block: 1024 slots per queue, batch=341

That's way too much, batch should just stay around 32, that is fine.

> Still very spiky, and during the write disk is uncapable of doing any
> reads. IOW, no serious application can be started before writing has
> finished. Shouldn't we favour reads over writes? Or is it just that
> the elevator is not doing its job right, so reads suffer?

You are probably just seeing starvation due to the very long queues.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
