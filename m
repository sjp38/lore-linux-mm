Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9FB576B004D
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 02:40:10 -0400 (EDT)
Received: by an-out-0708.google.com with SMTP id c3so1432157ana.26
        for <linux-mm@kvack.org>; Mon, 21 Sep 2009 23:40:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090921090445.GG12726@csn.ul.ie>
References: <202cde0e0909132230y52b805a4i8792f2e287b01acb@mail.gmail.com>
	 <20090914165435.GA21554@infradead.org>
	 <202cde0e0909162342xb2a8daeia90b33a172fc714b@mail.gmail.com>
	 <20090917091408.GB13002@csn.ul.ie>
	 <202cde0e0909202216i36e3eca3rc56ddde345b12bf9@mail.gmail.com>
	 <20090921090445.GG12726@csn.ul.ie>
Date: Tue, 22 Sep 2009 18:40:13 +1200
Message-ID: <202cde0e0909212340h740adb51pbab6981aa3c994da@mail.gmail.com>
Subject: Re: HugeTLB: Driver example
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Hellwig <hch@infradead.org>, Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>
> I can't. The request was from 9-10 months ago for drivers about about 18
> months ago for Xen when they were looking at this area. The authors are no
> longer working in that area AFAIK as once it was discussed what would need
> to be done to use huge pages, they balked. It's far easier now as most of
> the difficulties have been addressed but the interested parties are not
> likely to be looking at this area for some time.
>
> The most recent expression of interest was from KVM developers within the
> company. On discussion, using huge pages was something they were going to
> push out as there are other concerns that should be addressed first. I'd
> say it'd be at least a year before they looked at huge pages for KVM.
>
Ok. I see. Thanks.

>> It makes sense to get this
>> feature merged as it provides a quite efficient way for performance
>> increase. According to our test data, applying these little changes
>> gives about 7-10% gain.
>>
>
> What is this test data based on?

The test is based on the throughput of network packets processing. We
read the data from DMA buffers whose are mmaped to user space and then
parse packets by applications. If mapping is based on huge pages we
have gain ~7-10% (more mbps).  Actually I was surprised a bit when
find out that there is no possibility to have huge page mappings for
device drivers. Probably people just don't know about this.

Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
