Date: Tue, 11 Oct 2005 21:26:27 -0500
From: Robin Holt <holt@sgi.com>
Subject: [Patch 0/2] ia64 special memory support.
Message-ID: <20051012022627.GA32360@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

SGI hardware supports a special type of memory called fetchop or atomic
memory. This memory does atomic operations at the memory controller
instead of using the processor.  It has, however, shown itself to be
slower than the processor since many times that a lock is grabbed,
the cacheline ownership is retained in the processor and the unlock is
nearly free.

This patch set introduces a driver so userland can map these devices
and fault pages of the appropriate type.

Since a typical uncached page does not have a page struct backing it, we
first modify do_no_page to handle a new return type of NOPAGE_FAULTED.
This indicates to the nopage handler that the desired operation is
complete and should be treated as a minor fault.

The second patch introduces the mspec driver.

Thanks, Robin Holt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
