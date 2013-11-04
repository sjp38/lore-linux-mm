Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id DF34F6B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 15:03:49 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id wy17so4422661pbc.0
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 12:03:49 -0800 (PST)
Received: from psmtp.com ([74.125.245.191])
        by mx.google.com with SMTP id i8si2323392paa.329.2013.11.04.12.03.48
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 12:03:48 -0800 (PST)
Date: Mon, 4 Nov 2013 14:03:46 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: BUG: mm, numa: test segfaults, only when NUMA balancing is on
Message-ID: <20131104200346.GA3066@sgi.com>
References: <20131016155429.GP25735@sgi.com>
 <20131104145828.GA1218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131104145828.GA1218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 04, 2013 at 02:58:28PM +0000, Mel Gorman wrote:
> On Wed, Oct 16, 2013 at 10:54:29AM -0500, Alex Thorlton wrote:
> > Hi guys,
> > 
> > I ran into a bug a week or so ago, that I believe has something to do
> > with NUMA balancing, but I'm having a tough time tracking down exactly
> > what is causing it.  When running with the following configuration
> > options set:
> > 
> 
> Can you test with patches
> cd65718712469ad844467250e8fad20a5838baae..0255d491848032f6c601b6410c3b8ebded3a37b1
> applied? They fix some known memory corruption problems, were merged for
> 3.12 (so alternatively just test 3.12) and have been tagged for -stable.

I just finished testing with 3.12, and I'm still seeing the same issue.
This is actually a bit strange to me, because, when I tested with
3.12-rc5 a while back, everything seemed to be ok (see previoues e-mail
in this thread, to Bob Liu).  I guess, embarrasingly enough, I must have
been playing with a screwed up config that day, and managed to somehow
avoid the problem...  Either way, it appears that we still have a
problem here.

I'll poke around a bit more on this in the next few days and see if I
can come up with any more information.  In the meantime, let me know if
you have any other suggestions.

Thanks,

- Alex

> 
> Thanks.
> 
> -- 
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
