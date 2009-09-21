Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EF5E76B0114
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 01:16:21 -0400 (EDT)
Received: by yxe10 with SMTP id 10so3420274yxe.12
        for <linux-mm@kvack.org>; Sun, 20 Sep 2009 22:16:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090917091408.GB13002@csn.ul.ie>
References: <202cde0e0909132230y52b805a4i8792f2e287b01acb@mail.gmail.com>
	 <20090914165435.GA21554@infradead.org>
	 <202cde0e0909162342xb2a8daeia90b33a172fc714b@mail.gmail.com>
	 <20090917091408.GB13002@csn.ul.ie>
Date: Mon, 21 Sep 2009 17:16:26 +1200
Message-ID: <202cde0e0909202216i36e3eca3rc56ddde345b12bf9@mail.gmail.com>
Subject: Re: HugeTLB: Driver example
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Hellwig <hch@infradead.org>, Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Mel,

> I think Christoph's point is that there should be an in-kernel user of the
> altered interface to hugetlbfs before the patches are merged. This example
> driver could move to samples/ and then add another patch converting some
> existing driver to use the new interface. Looking at the example driver,
> I'm hoping that converting an existing driver of interest would not be a
> massive undertaking.

Converting an existing driver may be a very difficult task as this
assumes involving in development process of the particular driver i.e.
having enough details about h/w and drivers and  having ability to
test the results. Also it is necessary to motivate maintainers to
accept this conversion. So I likely would not to be able change the
third party drivers for these reasons, but I'm open to help other
people to migrate if they want.
I heard that other people were asking you about driver interfaces for
huge pages, if this was about in-tree drivers then we could help each
other. Could you put me in touch with other developers you know of who
are interested in using htlb in drivers? It makes sense to get this
feature merged as it provides a quite efficient way for performance
increase. According to our test data, applying these little changes
gives about 7-10% gain.


> I tend to agree with him.
>
> As I'm having trouble envisioning what a real driver would look like,
> converting an in-kernel driver ensures that the interface was sane instead
> of exporting symbols that turn out to be unusable later. It'll also force
> any objectors out of the closet sooner rather than later.
>
> As it stands, I have no problems with the patches as such other than they
> need a bit more spit and polish. The basic principal seems ok.

Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
