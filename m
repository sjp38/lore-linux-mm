Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id ABE406B006E
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 19:08:41 -0400 (EDT)
Message-ID: <502D7D6E.8090303@linux.intel.com>
Date: Thu, 16 Aug 2012 16:08:30 -0700
From: "H. Peter Anvin" <hpa@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH, RFC 0/9] Introduce huge zero page
References: <1344503300-9507-1-git-send-email-kirill.shutemov@linux.intel.com> <20120816122023.c0e9bbc0.akpm@linux-foundation.org> <20120816194024.GP11188@redhat.com>
In-Reply-To: <20120816194024.GP11188@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On 08/16/2012 12:40 PM, Andrea Arcangeli wrote:
> Hi Andrew,
> 
> On Thu, Aug 16, 2012 at 12:20:23PM -0700, Andrew Morton wrote:
>> That's a pretty big improvement for a rather fake test case.  I wonder
>> how much benefit we'd see with real workloads?
> 
> The same discussion happened about the zero page in general and
> there's no easy answer. I seem to recall that it was dropped at some
> point and then we reintroduced the zero page later.
> 
> Most of the time it won't be worth it, it's just a few pathological
> compute loads that benefits IIRC. So I'm overall positive about it
> (after it's stable).
> 
> Because this is done the right way (i.e. to allocate an hugepage at
> the first wp fault, and to fallback exclusively if compaction fails)
> it will help much less than the 4k zero pages if the zero pages are
> scattered over the address space and not contiguous (it only helps if
> there are 512 of them in a row). OTOH if they're contiguous, the huge
> zero pages will perform better than the 4k zero pages.
> 

One thing that I asked for testing a "virtual zero page" where the same
page (or N pages for N-way page coloring) is reused across a page table.
 It would have worse TLB performance but likely *much* better cache
behavior.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
