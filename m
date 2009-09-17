Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2512B6B004F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 05:14:05 -0400 (EDT)
Date: Thu, 17 Sep 2009 10:14:08 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: HugeTLB: Driver example
Message-ID: <20090917091408.GB13002@csn.ul.ie>
References: <202cde0e0909132230y52b805a4i8792f2e287b01acb@mail.gmail.com> <20090914165435.GA21554@infradead.org> <202cde0e0909162342xb2a8daeia90b33a172fc714b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <202cde0e0909162342xb2a8daeia90b33a172fc714b@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolex@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 17, 2009 at 06:42:20PM +1200, Alexey Korolev wrote:
> >> There is an example of simple driver which provides huge pages mapping
> >> for user level applications. The  procedure for mapping of huge pages
> >> to userspace by the driver is:
> >>
> >> 1. Create a hugetlb file on vfs mount of hugetlbfs (h_file)
> >
> > Note that to get your support code included at all you'll need a real
> > intree driver, not just an example.  That is if VM people are happy with
> > the general concept.
>
> Hi,
> The driver example listed here takes the same approach as already done
> inside ipc/shm.c. So people can refer this file for development. The
> patches just make existing functions more usable by drivers and this
> example is an extract of ipc/shm.c in order to give pretty simple
> how-to.

I think Christoph's point is that there should be an in-kernel user of the
altered interface to hugetlbfs before the patches are merged. This example
driver could move to samples/ and then add another patch converting some
existing driver to use the new interface. Looking at the example driver,
I'm hoping that converting an existing driver of interest would not be a
massive undertaking.

I tend to agree with him.

As I'm having trouble envisioning what a real driver would look like,
converting an in-kernel driver ensures that the interface was sane instead
of exporting symbols that turn out to be unusable later. It'll also force
any objectors out of the closet sooner rather than later.

As it stands, I have no problems with the patches as such other than they
need a bit more spit and polish. The basic principal seems ok.

> Seems I gave a not so good description for this patch set so it caused
> a lot of misunderstanding, sorry about that.
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
