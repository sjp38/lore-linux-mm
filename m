Received: by wx-out-0102.google.com with SMTP id s17so206102wxc
        for <linux-mm@kvack.org>; Wed, 21 Jun 2006 15:25:07 -0700 (PDT)
Message-ID: <5c49b0ed0606211525i57628af5yaef46ee4e1820339@mail.gmail.com>
Date: Wed, 21 Jun 2006 15:25:05 -0700
From: "Nate Diller" <nate.diller@gmail.com>
Subject: Re: [PATCH] mm/tracking dirty pages: update get_dirty_limits for mmap tracking
In-Reply-To: <20060621180857.GA6948@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <5c49b0ed0606211001s452c080cu3f55103a130b78f1@mail.gmail.com>
	 <20060621180857.GA6948@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Linus Torvalds <torvalds@osdl.org>, Hans Reiser <reiser@namesys.com>, "E. Gryaznova" <grev@namesys.com>
List-ID: <linux-mm.kvack.org>

On 6/21/06, Nick Piggin <npiggin@suse.de> wrote:
> On Wed, Jun 21, 2006 at 10:01:17AM -0700, Nate Diller wrote:
> > Update write throttling calculations now that we can track and
> > throttle dirty mmap'd pages.  A version of this patch has been tested
> > with iozone:
>
> Your changelog doesn't tell much about the "why" side of things,
> and omits the fact that you have upped the dirty ratio to 80.

hmm, you are right, documenting it in the code comment is not really
enough here, because there are going to be performance corner cases
and such for this patch (as well as the whole tracking dirty patchset)

> >
> > http://namesys.com/intbenchmarks/iozone/06.06.19.tracking.dirty.page-noatime_-B/e3-2.6.16-tr.drt.pgs-rt.40_vs_rt.80.html
> > http://namesys.com/intbenchmarks/iozone/06.06.19.tracking.dirty.page-noatime_-B/r4-2.6.16-tr.drt.pgs-rt.40_vs_rt.80.html
>
> I'm guessing the reason you get all those red numbers when
> iozone files are larger than RAM is because writeout and reclaim
> tend to get worse when there are large amounts of dirty pages
> floating around in memory?

actually, there is a great deal of variation in the test results once
you get into the large I/O part of the test.  also, the fact that we
are tracking mmap'd pages at all changes the preformance.  here are
links which compare the old and new configurations, but with
dirty_pages set to 40 on both:

http://namesys.com/intbenchmarks/iozone/06.06.19.tracking.dirty.page-noatime_-B/e3-2.6.16_vs_tr.drt.pgs-rt.40.html
http://namesys.com/intbenchmarks/iozone/06.06.19.tracking.dirty.page-noatime_-B/r4-2.6.16_vs_tr.drt.pgs-rt.40.html

grev posted the variance as well, but for some reason the link doesn't work.

NATE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
