Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 4AF846B0044
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 15:40:29 -0400 (EDT)
Date: Thu, 16 Aug 2012 21:40:24 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH, RFC 0/9] Introduce huge zero page
Message-ID: <20120816194024.GP11188@redhat.com>
References: <1344503300-9507-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20120816122023.c0e9bbc0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120816122023.c0e9bbc0.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

Hi Andrew,

On Thu, Aug 16, 2012 at 12:20:23PM -0700, Andrew Morton wrote:
> That's a pretty big improvement for a rather fake test case.  I wonder
> how much benefit we'd see with real workloads?

The same discussion happened about the zero page in general and
there's no easy answer. I seem to recall that it was dropped at some
point and then we reintroduced the zero page later.

Most of the time it won't be worth it, it's just a few pathological
compute loads that benefits IIRC. So I'm overall positive about it
(after it's stable).

Because this is done the right way (i.e. to allocate an hugepage at
the first wp fault, and to fallback exclusively if compaction fails)
it will help much less than the 4k zero pages if the zero pages are
scattered over the address space and not contiguous (it only helps if
there are 512 of them in a row). OTOH if they're contiguous, the huge
zero pages will perform better than the 4k zero pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
