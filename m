Subject: Re: [PATCH]: Adding a counter in vma to indicate the number
	of	physical pages backing it
From: Rohit Seth <rohitseth@google.com>
Reply-To: rohitseth@google.com
In-Reply-To: <200606121958.41127.ak@suse.de>
References: <1149903235.31417.84.camel@galaxy.corp.google.com>
	 <448A762F.7000105@yahoo.com.au>
	 <1150133795.9576.19.camel@galaxy.corp.google.com>
	 <200606121958.41127.ak@suse.de>
Content-Type: text/plain
Date: Mon, 12 Jun 2006 12:42:49 -0700
Message-Id: <1150141369.9576.43.camel@galaxy.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, Linux-mm@kvack.org, Linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2006-06-12 at 19:58 +0200, Andi Kleen wrote:
> > It is just the price of those walks that makes smaps not an attractive
> > solution for monitoring purposes.
> 
> It just shouldn't be used for that. It's a debugging hack and not really 
> suitable for monitoring even with optimizations.
> 
> For monitoring if the current numa statistics are not good enough
> you should probably propose new counters.


numa stats are giving different data.  The proposed vma->nr_phys is the
new counter that can provide a detailed information about physical mem
usage at each virtual mem segment level.  I think having this
information in each vma keeps the impact (of adding new counter) to very
low.

Second question is to advertize this value to user space.  Please let me
know what suites the most among /proc, /sys or system call (or if there
is any other mechanism then let me know) for a per process per segment
related information.

-rohit



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
