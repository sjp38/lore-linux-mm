Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id AE2556B0069
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 18:46:09 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id g202so16710492ita.4
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 15:46:09 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0208.hostedemail.com. [216.40.44.208])
        by mx.google.com with ESMTPS id l129si7306016itd.167.2017.12.11.15.46.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Dec 2017 15:46:08 -0800 (PST)
Message-ID: <1513035963.3036.17.camel@perches.com>
Subject: Re: [PATCH v4 72/73] xfs: Convert mru cache to XArray
From: Joe Perches <joe@perches.com>
Date: Mon, 11 Dec 2017 15:46:03 -0800
In-Reply-To: <20171211224301.GA3925@bombadil.infradead.org>
References: <fd7130d7-9066-524e-1053-a61eeb27cb36@lge.com>
	 <Pine.LNX.4.44L0.1712081228430.1371-100000@iolanthe.rowland.org>
	 <20171208223654.GP5858@dastard> <1512838818.26342.7.camel@perches.com>
	 <20171211214300.GT5858@dastard> <1513030348.3036.5.camel@perches.com>
	 <20171211224301.GA3925@bombadil.infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Whitcroft <apw@shadowen.org>
Cc: Dave Chinner <david@fromorbit.com>, Alan Stern <stern@rowland.harvard.edu>, Byungchul Park <byungchul.park@lge.com>, Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Mon, 2017-12-11 at 14:43 -0800, Matthew Wilcox wrote:
> On Mon, Dec 11, 2017 at 02:12:28PM -0800, Joe Perches wrote:
> > Completely reasonable.  Thanks.
> 
> If we're doing "completely reasonable" complaints, then ...
> 
>  - I don't understand why plain 'unsigned' is deemed bad.

That was a David Miller preference.

>  - The rule about all function parameters in prototypes having a name
>    doesn't make sense.  Example:
> 
> int ida_get_new_above(struct ida *ida, int starting_id, int *p_id);

Improvements to regex welcomed.

>  - Forcing a blank line after variable declarations sometimes makes for
>    some weird-looking code.

True.  I don't care for this one myself.
>    Constructively, I think this warning can be suppressed for blocks
>    that are under, say, 8 lines.

Not easy to do as checkpatch works on patches.

> 6) Functions
> ------------
> 
> Functions should be short and sweet, and do just one thing.  They should
> fit on one or two screenfuls of text (the ISO/ANSI screen size is 80x24,
> as we all know), and do one thing and do that well.
> 
>    I'm not expecting you to be able to write a perl script that checks
>    the first line, but we have way too many 200-plus line functions in
>    the kernel.  I'd like a warning on anything over 200 lines (a factor
>    of 4 over Linus's stated goal).

Maybe reasonable.
Some declaration blocks for things like:

void foo(void)
{
	static const struct foobar array[] = {
		{ long count of lines... };
	[body]
}

might make that warning unreasonable though.

>  - I don't understand the error for xa_head here:
> 
> struct xarray {
>         spinlock_t      xa_lock;
>         gfp_t           xa_flags;
>         void __rcu *    xa_head;
> };
> 
>    Do people really think that:
> 
> struct xarray {
>         spinlock_t      xa_lock;
>         gfp_t           xa_flags;
>         void __rcu	*xa_head;
> };
> 
>    is more aesthetically pleasing?  And not just that, but it's an *error*
>    so the former is *RIGHT* and this is *WRONG*.  And not just a matter
>    of taste?

No opinion really.
That's from Andy Whitcroft's original implementation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
