Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 175ZiE-0007RJ-00
	for <linux-mm@kvack.org>; Wed, 08 May 2002 15:15:06 -0700
Date: Wed, 8 May 2002 15:15:06 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: [RFC] tabulating page->virtual on highmem
Message-ID: <20020508221506.GL15756@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The size of the kmap pool appears to dictate the number of distinct
values of page->virtual. Maintaining an index into the pool would
seem to provide superior space behavior, as the index need not be
of full machine word precision. Furthermore, no auxiliary lookup
would appear to be required as the kmap pool is virtually contiguous
and so the virtual address could be calculated from base virtual
address of the kmap pool and the index into the pool.

For architectures using page->virtual for page_address() calculation
this technique does not apply, and so page->virtual would then need
to be maintained as is, or at least retain enough precision for a full
page frame number.

I don't have my heart set on this but I thought I'd at least throw the
idea out where its desirability (and potential implementations) could
be discussed.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
