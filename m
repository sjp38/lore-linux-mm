Date: Sun, 29 Aug 2004 10:52:34 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on swap partition
Message-ID: <20040829175234.GQ5492@holomorphy.com>
References: <412E13DB.6040102@seagha.com> <412E31EE.3090102@pandora.be> <41308C62.7030904@seagha.com> <20040828125028.2fa2a12b.akpm@osdl.org> <4130F55A.90705@pandora.be> <20040828144303.0ae2bebe.akpm@osdl.org> <20040828215411.GY5492@holomorphy.com> <20040828151349.00f742f4.akpm@osdl.org> <20040828222816.GZ5492@holomorphy.com> <20040829165458.GD11219@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040829165458.GD11219@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, karl.vogel@pandora.be, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 28 2004, William Lee Irwin III wrote:
>> It certainly appears to be the deciding factor from the thread.

On Sun, Aug 29, 2004 at 06:54:59PM +0200, Jens Axboe wrote:
> Has nothing to do with the io scheduler itself, apart from the fact that
> CFQ exposes the problem by setting a larger q->nr_requests. And that is
> the very deciding factor, not the io scheduler.

Then it's narrower still, q->nr_requests. What a priori reasons are
there for this to vomit? clear_queue_congested() seems to be called
only when a request is retired, so a large number of requests in flight
may be doing something unexpected, and I'd expect large q->nr_requests
to keep large numbers of requests around. Hmm...


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
