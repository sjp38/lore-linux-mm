Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F21D86006B4
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 15:58:53 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <4f986c65-c17e-47d8-9c30-60cd17809cbb@default>
Date: Mon, 19 Jul 2010 12:57:24 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 0/8] zcache: page cache compression support
References: <1279283870-18549-1-git-send-email-ngupta@vflare.org>
In-Reply-To: <1279283870-18549-1-git-send-email-ngupta@vflare.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Christoph Hellwig <hch@infradead.org>, Minchan Kim <minchan.kim@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> We only keep pages that compress to PAGE_SIZE/2 or less. Compressed
> chunks are
> stored using xvmalloc memory allocator which is already being used by
> zram
> driver for the same purpose. Zero-filled pages are checked and no
> memory is
> allocated for them.

I'm curious about this policy choice.  I can see why one
would want to ensure that the average page is compressed
to less than PAGE_SIZE/2, and preferably PAGE_SIZE/2
minus the overhead of the data structures necessary to
track the page.  And I see that this makes no difference
when the reclamation algorithm is random (as it is for
now).  But once there is some better reclamation logic,
I'd hope that this compression factor restriction would
be lifted and replaced with something much higher.  IIRC,
compression is much more expensive than decompression
so there's no CPU-overhead argument here either,
correct?

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
