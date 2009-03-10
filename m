Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1F5706B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 18:45:40 -0400 (EDT)
Date: Tue, 10 Mar 2009 15:49:11 -0700
From: mark gross <mgross@linux.intel.com>
Subject: Re: possible bug in find_get_pages
Message-ID: <20090310224911.GA16630@linux.intel.com>
Reply-To: mgross@linux.intel.com
References: <20090306192625.GA3267@linux.intel.com> <20090307084732.b01bcfee.minchan.kim@barrios-desktop> <20090309164316.GB31140@linux.intel.com> <20090310104552.GA4594@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090310104552.GA4594@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 10, 2009 at 11:45:52AM +0100, Nick Piggin wrote:
> On Mon, Mar 09, 2009 at 09:43:16AM -0700, mark gross wrote:
> > On Sat, Mar 07, 2009 at 08:47:32AM +0900, Minchan Kim wrote:
> > > Nick already found and solved this problem .
> > > It can help you. 
> > > 
> > > http://patchwork.kernel.org/patch/860/
> > > 
> > 
> > Wow, this reads just like the problem we are seeing.  I'll try the
> > patch and let the test run for a few days!
> > 
> > We've even see it come out of the live lock once in a while as well.  I
> > was thinking cache coherency HW issue until this :)
> > 
> > I'll send an update after running the test.
> 
> Note that after some discussion, the accepted fix looks a bit
> different (and might potentially fix another problem if the compiler
> gets very smart, although gcc doesn't seem to).
> 
> Git commit e8c82c2e23e3527e0c9dc195e432c16784d270fa

Yes, we are testing with this one liner fix, 30rhs and counting.  Its
looking pretty good.

thanks!

--mgross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
