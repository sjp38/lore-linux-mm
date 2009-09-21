Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 865676B00A3
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 05:04:45 -0400 (EDT)
Date: Mon, 21 Sep 2009 10:04:46 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: HugeTLB: Driver example
Message-ID: <20090921090445.GG12726@csn.ul.ie>
References: <202cde0e0909132230y52b805a4i8792f2e287b01acb@mail.gmail.com> <20090914165435.GA21554@infradead.org> <202cde0e0909162342xb2a8daeia90b33a172fc714b@mail.gmail.com> <20090917091408.GB13002@csn.ul.ie> <202cde0e0909202216i36e3eca3rc56ddde345b12bf9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <202cde0e0909202216i36e3eca3rc56ddde345b12bf9@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolex@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 21, 2009 at 05:16:26PM +1200, Alexey Korolev wrote:
> Mel,
> 
> > I think Christoph's point is that there should be an in-kernel user of the
> > altered interface to hugetlbfs before the patches are merged. This example
> > driver could move to samples/ and then add another patch converting some
> > existing driver to use the new interface. Looking at the example driver,
> > I'm hoping that converting an existing driver of interest would not be a
> > massive undertaking.
> 
> Converting an existing driver may be a very difficult task as this
> assumes involving in development process of the particular driver i.e.
> having enough details about h/w and drivers and  having ability to
> test the results.

I had assumed that you had a driver in mind as you discussed test data.
I assumed you had a prototype conversion of some driver and with
performance gains like that, they would be willing to get it in a
mergeable state.

> Also it is necessary to motivate maintainers to
> accept this conversion. So I likely would not to be able change the
> third party drivers for these reasons, but I'm open to help other
> people to migrate if they want.
> I heard that other people were asking you about driver interfaces for
> huge pages, if this was about in-tree drivers then we could help each
> other. Could you put me in touch with other developers you know of who
> are interested in using htlb in drivers?

I can't. The request was from 9-10 months ago for drivers about about 18
months ago for Xen when they were looking at this area. The authors are no
longer working in that area AFAIK as once it was discussed what would need
to be done to use huge pages, they balked. It's far easier now as most of
the difficulties have been addressed but the interested parties are not
likely to be looking at this area for some time.

The most recent expression of interest was from KVM developers within the
company. On discussion, using huge pages was something they were going to
push out as there are other concerns that should be addressed first. I'd
say it'd be at least a year before they looked at huge pages for KVM.

> It makes sense to get this
> feature merged as it provides a quite efficient way for performance
> increase. According to our test data, applying these little changes
> gives about 7-10% gain.
> 

What is this test data based on?

> > I tend to agree with him.
> >
> > As I'm having trouble envisioning what a real driver would look like,
> > converting an in-kernel driver ensures that the interface was sane instead
> > of exporting symbols that turn out to be unusable later. It'll also force
> > any objectors out of the closet sooner rather than later.
> >
> > As it stands, I have no problems with the patches as such other than they
> > need a bit more spit and polish. The basic principal seems ok.
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
