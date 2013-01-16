Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 419B76B006C
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 05:41:26 -0500 (EST)
Date: Wed, 16 Jan 2013 11:41:20 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: LSF 2013 call for participation?
Message-ID: <20130116104120.GC29162@quack.suse.cz>
References: <20130107123719.GA14255@quack.suse.cz>
 <yq1fw2dxaly.fsf@sermon.lab.mkp.net>
 <20130115231127.GA6422@blackbox.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130115231127.GA6422@blackbox.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>, Jan Kara <jack@suse.cz>, James.Bottomley@HansenPartnership.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Tue 15-01-13 15:11:27, Darrick J. Wong wrote:
> [adding linux-mm to cc...]
> 
> On Mon, Jan 07, 2013 at 10:43:05AM -0500, Martin K. Petersen wrote:
> > >>>>> "Jan" == Jan Kara <jack@suse.cz> writes:
> > 
> > Jan> Hi, I wanted to ask about this year's LSFMM summit - I didn't see
> > Jan> any call for participation yet although previous years it was sent
> > Jan> out before Christmas. 
> > 
> > Really? I always thought they went out in January. In any case we are
> > getting the call rolling.
> > 
> > And for those that want to plan ahead the dates are April 18th and 19th
> > in San Francisco. This year we're trailing the Collab Summit instead of
> > preceding it:
> > 
> > 	https://events.linuxfoundation.org/events/lsfmm-summit
> 
> There are a few things I'd like to hold a discussion about...
...
>  - Stable pages part 3: Modifying existing block devices.  A number of block
>    devices and filesystems provide their own page snapshotting, or play tricks
>    with the page bits to satisfy their own stability requirements.  Can we
>    eliminate this?
  I guess this is more about sending patches than agreeing on how to do
it. But you can give a quick status update so that respective maintainers
know about the current situation.

> Also, miscellaneous other odd topics:
> 
>  - How many of the infrequently-tested mount options in ext4/others can we get
>    away with eliminating?  Or at least hiding them behind a "pleaseeatmydata"
>    mount flag to minimize (hopefully) the amount of accidental data loss due to
>    wild mount incantations?
  I'm interested in this discussion as well. But be aware that this
question is coming up for at least last two years if I remember right. And
again if you come up with suggestions for particular options, we can speak
about it. Actually I have a plan to prepare some concrete suggestions for
ext4 workshop / LSF. So just tell me if you plan to work on this so that we
don't duplicate the effort.

>  - A discussion of deduplication could be fun, though I'm not sure its memory
>    and processing requirements make it a great candidate for kernel code, or
>    even general usage.  I'm not even sure there's a practical way to, say, have
>    a userspace dedupe tool that could listen for delayed allocations and try to
>    suggest adjustments before commit time.
  I think userspace is a better place for efficient deduplication... Plus
you have to implement COW to handle when deduplicated block is written.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
