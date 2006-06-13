From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH]: Adding a counter in vma to indicate the number =?iso-8859-15?q?of=09physical_pages_backing?= it
Date: Tue, 13 Jun 2006 05:51:23 +0200
References: <1149903235.31417.84.camel@galaxy.corp.google.com> <200606121958.41127.ak@suse.de> <1150141369.9576.43.camel@galaxy.corp.google.com>
In-Reply-To: <1150141369.9576.43.camel@galaxy.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606130551.23825.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: rohitseth@google.com
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, Linux-mm@kvack.org, Linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Monday 12 June 2006 21:42, Rohit Seth wrote:
> On Mon, 2006-06-12 at 19:58 +0200, Andi Kleen wrote:
> > > It is just the price of those walks that makes smaps not an attractive
> > > solution for monitoring purposes.
> > 
> > It just shouldn't be used for that. It's a debugging hack and not really 
> > suitable for monitoring even with optimizations.
> > 
> > For monitoring if the current numa statistics are not good enough
> > you should probably propose new counters.
> 
> 
> numa stats are giving different data.  The proposed vma->nr_phys is the
> new counter that can provide a detailed information about physical mem
> usage at each virtual mem segment level.  

And for what do you need that?

It's somewhat useful to debug the NUMA tuning of your app (although
there are other ways to do that too) but do you
really need it for normal runtime monitoring? 


> I think having this 
> information in each vma keeps the impact (of adding new counter) to very
> low.
> 
> Second question is to advertize this value to user space.  Please let me
> know what suites the most among /proc, /sys or system call (or if there
> is any other mechanism then let me know) for a per process per segment
> related information.

I think we first need to identify the basic need.
Don't see why we even need per VMA information so far.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
