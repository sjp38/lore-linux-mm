Date: Wed, 23 Oct 2002 04:05:34 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] generic nonlinear mappings, 2.5.44-mm2-D0
Message-ID: <20021023020534.GJ11242@dualathlon.random>
References: <20021022184938.A2395@infradead.org> <Pine.LNX.4.44.0210222204330.21530-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0210222204330.21530-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@zip.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 22, 2002 at 10:19:37PM +0200, Ingo Molnar wrote:
> protection bits. It has been clearly established in the past few years
> empirically that the vma tree approach itself sucks performance-wise for
> applications that have many different mappings.

if you're talking about get_unmapped_area showing up heavy on the
profiling then you're on the wrong track with this, if nobody beats me I
will fix that one soon right, I discussed that some month ago with Claus
Fisher and it's going to be optimized away completely from all
profilings out there (at least as much as mmap). The vma ram overhead
will be still there though, just the cpu overhead will go away, but I
never heard anybody complaining about finishing ram because of vmas yet
(while I know several cases where the lack of O(log(N)) in
get_unmapped_area is a showstopper, the GUI as well suffers badly with
the hundred of librarians but the guis are otherwise idle so it doesn't
matter much for them if the cpu is wasted but they will get a bit lower
latency).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
