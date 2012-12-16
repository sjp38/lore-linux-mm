Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id A262C6B002B
	for <linux-mm@kvack.org>; Sat, 15 Dec 2012 23:15:53 -0500 (EST)
Date: Sun, 16 Dec 2012 15:15:49 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] fadvise: perform WILLNEED readahead in a workqueue
Message-ID: <20121216041549.GK9806@dastard>
References: <20121215005448.GA7698@dcvr.yhbt.net>
 <20121215223448.08272fd5@pyramind.ukuu.org.uk>
 <20121216002549.GA19402@dcvr.yhbt.net>
 <20121216030302.GI9806@dastard>
 <20121216033549.GA30446@dcvr.yhbt.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121216033549.GA30446@dcvr.yhbt.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wong <normalperson@yhbt.net>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Dec 16, 2012 at 03:35:49AM +0000, Eric Wong wrote:
> Dave Chinner <david@fromorbit.com> wrote:
> > On Sun, Dec 16, 2012 at 12:25:49AM +0000, Eric Wong wrote:
> > > Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> > > > On Sat, 15 Dec 2012 00:54:48 +0000
> > > > Eric Wong <normalperson@yhbt.net> wrote:
> > > > 
> > > > > Applications streaming large files may want to reduce disk spinups and
> > > > > I/O latency by performing large amounts of readahead up front

> This could also be a use case for an audio/video player.

Sure, but this can all be handled by a userspace application. If you
want to avoid/batch IO to enable longer spindown times, then you
have to load the file into RAM somewhere, and you don't need special
kernel support for that.

> So no, there's no difference that matters between the approaches.
> But I think doing this in the kernel is easier for userspace users.

The kernel provides mechanisms for applications to use. You have not
mentioned anything new that requires a new kernel mechanism to
acheive - you just need to have the knowledge to put the pieces
together properly.  People have been solving this same problem for
the last 20 years without needing to tweak fadvise(). Or even having
an fadvise() syscall...

Nothing about low latency IO or streaming IO is simple or easy, and
changing how readahead works doesn't change that fact. All it does
is change the behaviour of every other application that uses
fadvise() to minimise IO latency....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
