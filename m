Date: Sat, 24 Mar 2007 07:40:30 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 1/2] hugetlb: add resv argument to hugetlb_file_setup
Message-ID: <20070324074030.GA18408@infradead.org>
References: <b040c32a0703231542r77030723o214255a5fa591dec@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b040c32a0703231542r77030723o214255a5fa591dec@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Adam Litke <agl@us.ibm.com>, William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 23, 2007 at 03:42:13PM -0700, Ken Chen wrote:
> rename hugetlb_zero_setup() to hugetlb_file_setup() to better match
> function name convention like shmem implementation.  Also add an
> argument to the function to indicate whether file setup should reserve
> hugetlb page upfront or not.

I think the reservation call should be move out of this function entirely.
We only return the file descriptors through the syscall we're in, and
the dentries never appear in any namespace, so there is not reason to
do the reservation early.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
