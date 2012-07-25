Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 8FF616B004D
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 15:38:06 -0400 (EDT)
Date: Wed, 25 Jul 2012 14:38:00 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH, RFC 0/6] Avoid cache trashing on clearing huge/gigantic
 page
In-Reply-To: <20120725192850.GA4952@tassilo.jf.intel.com>
Message-ID: <alpine.DEB.2.00.1207251434280.4995@router.home>
References: <1342788622-10290-1-git-send-email-kirill.shutemov@linux.intel.com> <alpine.DEB.2.00.1207251346250.4995@router.home> <20120725192850.GA4952@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Tim Chen <tim.c.chen@linux.intel.com>, Alex Shi <alex.shu@intel.com>, Jan Beulich <jbeulich@novell.com>, Robert Richter <robert.richter@amd.com>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org

On Wed, 25 Jul 2012, Andi Kleen wrote:

> > why exempt the 4K around the fault address? Is there a regression if that
> > is not exempted?
>
> You would get an immediate cache miss when the faulting instruction
> is reexecuted.

Nope. You would not get cache misses for all cachelines in the 4k range.
Only one.

> > I guess for anonymous huge pages one may assume that there will be at
> > least one write to one cache line in the 4k page. Is it useful to get all
> > the cachelines in the page in the cache.
>
> We did some measurements -- comparing 4K and 2MB with some tracing
> of fault patterns -- and a lot of apps don't use the full 2MB area.
> The apps with THP regressions usually used less than others.
> The patchkit significantly reduced some of the regressions.

Yup they wont use the full 2MB area. But are they using all the cache
lines of the 4k page that we are making hot?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
