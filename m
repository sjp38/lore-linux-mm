Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0D2DE6B005A
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 12:54:31 -0400 (EDT)
Date: Mon, 14 Sep 2009 12:54:35 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: HugeTLB: Driver example
Message-ID: <20090914165435.GA21554@infradead.org>
References: <202cde0e0909132230y52b805a4i8792f2e287b01acb@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <202cde0e0909132230y52b805a4i8792f2e287b01acb@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolex@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 14, 2009 at 05:30:12PM +1200, Alexey Korolev wrote:
> There is an example of simple driver which provides huge pages mapping
> for user level applications. The  procedure for mapping of huge pages
> to userspace by the driver is:
> 
> 1. Create a hugetlb file on vfs mount of hugetlbfs (h_file)

Note that to get your support code included at all you'll need a real
intree driver, not just an example.  That is if VM people are happy with
the general concept.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
