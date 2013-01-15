Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id B3B086B006C
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 18:11:33 -0500 (EST)
Date: Tue, 15 Jan 2013 15:11:27 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: LSF 2013 call for participation?
Message-ID: <20130115231127.GA6422@blackbox.djwong.org>
References: <20130107123719.GA14255@quack.suse.cz>
 <yq1fw2dxaly.fsf@sermon.lab.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <yq1fw2dxaly.fsf@sermon.lab.mkp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Martin K. Petersen" <martin.petersen@oracle.com>
Cc: Jan Kara <jack@suse.cz>, James.Bottomley@HansenPartnership.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

[adding linux-mm to cc...]

On Mon, Jan 07, 2013 at 10:43:05AM -0500, Martin K. Petersen wrote:
> >>>>> "Jan" == Jan Kara <jack@suse.cz> writes:
> 
> Jan> Hi, I wanted to ask about this year's LSFMM summit - I didn't see
> Jan> any call for participation yet although previous years it was sent
> Jan> out before Christmas. 
> 
> Really? I always thought they went out in January. In any case we are
> getting the call rolling.
> 
> And for those that want to plan ahead the dates are April 18th and 19th
> in San Francisco. This year we're trailing the Collab Summit instead of
> preceding it:
> 
> 	https://events.linuxfoundation.org/events/lsfmm-summit

There are a few things I'd like to hold a discussion about...

 - How do we get from bcache/flashcache/dm-cache/enhanceio to a single upstream
   driver?  If we merge one of them, then can we cherry-pick the more easily
   pluggable pieces of each into whatever gets merged?  Which one would we
   merge as a basis for the others?

 - Stable pages part 3: Modifying existing block devices.  A number of block
   devices and filesystems provide their own page snapshotting, or play tricks
   with the page bits to satisfy their own stability requirements.  Can we
   eliminate this?

Also, miscellaneous other odd topics:

 - How many of the infrequently-tested mount options in ext4/others can we get
   away with eliminating?  Or at least hiding them behind a "pleaseeatmydata"
   mount flag to minimize (hopefully) the amount of accidental data loss due to
   wild mount incantations?

 - Update on exposing T10/DIF data to userspace via the preadv/pwritev aio
   interface.  I ought to publish some code first.

 - A discussion of deduplication could be fun, though I'm not sure its memory
   and processing requirements make it a great candidate for kernel code, or
   even general usage.  I'm not even sure there's a practical way to, say, have
   a userspace dedupe tool that could listen for delayed allocations and try to
   suggest adjustments before commit time.

--D
> 
> -- 
> Martin K. Petersen	Oracle Linux Engineering
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
