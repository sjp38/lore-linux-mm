Message-ID: <417FBB6D.90401@pobox.com>
Date: Wed, 27 Oct 2004 11:14:53 -0400
From: Jeff Garzik <jgarzik@pobox.com>
MIME-Version: 1.0
Subject: Re: news about IDE PIO HIGHMEM bug (was: Re: 2.6.9-mm1)
References: <58cb370e041027074676750027@mail.gmail.com>
In-Reply-To: <58cb370e041027074676750027@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Cc: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, "Randy.Dunlap" <rddunlap@osdl.org>, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <axboe@suse.de>
List-ID: <linux-mm.kvack.org>

Bartlomiej Zolnierkiewicz wrote:
> We have stuct page of the first page and a offset.
> We need to obtain struct page of the current page and map it.


Opening this question to a wider audience.

struct scatterlist gives us struct page*, and an offset+length pair. 
The struct page* is the _starting_ page of a potentially multi-page run 
of data.

The question:  how does one get struct page* for the second, and 
successive pages in a known-contiguous multi-page run, if one only knows 
the first page?

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
