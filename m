Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 302C86B03C1
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 19:37:43 -0400 (EDT)
Received: by dakp5 with SMTP id p5so7356843dak.14
        for <linux-mm@kvack.org>; Mon, 25 Jun 2012 16:37:42 -0700 (PDT)
Date: Mon, 25 Jun 2012 16:37:37 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 2/3] zsmalloc: add generic path and remove x86 dependency
Message-ID: <20120625233737.GA3493@kroah.com>
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1340640878-27536-3-git-send-email-sjenning@linux.vnet.ibm.com>
 <20120625165915.GA20464@kroah.com>
 <4FE89BA1.3030709@linux.vnet.ibm.com>
 <20120625171939.GA29371@kroah.com>
 <4FE8ACDD.3070007@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FE8ACDD.3070007@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On Mon, Jun 25, 2012 at 01:24:29PM -0500, Seth Jennings wrote:
> On 06/25/2012 12:19 PM, Greg Kroah-Hartman wrote:
> > On Mon, Jun 25, 2012 at 12:10:57PM -0500, Seth Jennings wrote:
> >> On 06/25/2012 11:59 AM, Greg Kroah-Hartman wrote:
> >>> On Mon, Jun 25, 2012 at 11:14:37AM -0500, Seth Jennings wrote:
> >>>> This patch adds generic pages mapping methods that
> >>>> work on all archs in the absence of support for
> >>>> local_tlb_flush_kernel_range() advertised by the
> >>>> arch through __HAVE_LOCAL_TLB_FLUSH_KERNEL_RANGE
> >>>
> >>> Is this #define something that other arches define now?  Or is this
> >>> something new that you are adding here?
> >>
> >> Something new I'm adding.
> > 
> > Ah, ok.
> > 
> >> The precedent for this approach is the __HAVE_ARCH_* defines
> >> that let the arch independent stuff know if a generic
> >> function needs to be defined or if there is an arch specific
> >> function.
> >>
> >> You can "grep -R __HAVE_ARCH_* arch/x86/" to see the ones
> >> that already exist.
> >>
> >> I guess I should have called it
> >> __HAVE_ARCH_LOCAL_TLB_FLUSH_KERNEL_RANGE though, not
> >> __HAVE_LOCAL_TLB_FLUSH_KERNEL_RANGE.
> > 
> > You need to get the mm developers to agree with this before I can take
> > it.
> > 
> > But, why even depend on this?  Can't you either live without it
> 
> The whole point of the patch is _not_ to depend on it.  It
> just performs worse without it.  We could just rip out all
> the the page table assisted page mapping, but, for the
> arches that have support for it, we'd be degrading
> performance in exchange for portability.  Why choose when we
> can have both?

Ok, I'll let you fight it out with the mm people before applying these 2
patches, I've applied the first one only for now.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
