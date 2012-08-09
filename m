Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id CE4BF6B0075
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 11:18:55 -0400 (EDT)
Message-ID: <5023D4CE.7080704@zytor.com>
Date: Thu, 09 Aug 2012 08:18:38 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH, RFC 0/6] Avoid cache trashing on clearing huge/gigantic
 page
References: <1342788622-10290-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1342788622-10290-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alex Shi <alex.shu@intel.com>, Jan Beulich <jbeulich@novell.com>, Robert Richter <robert.richter@amd.com>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org

On 07/20/2012 05:50 AM, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>
> Clearing a 2MB huge page will typically blow away several levels of CPU
> caches.  To avoid this only cache clear the 4K area around the fault
> address and use a cache avoiding clears for the rest of the 2MB area.
>
> It would be nice to test the patchset with more workloads. Especially if
> you see performance regression with THP.
>
> Any feedback is appreciated.
>
> Andi Kleen (6):
>    THP: Use real address for NUMA policy
>    mm: make clear_huge_page tolerate non aligned address
>    THP: Pass real, not rounded, address to clear_huge_page
>    x86: Add clear_page_nocache
>    mm: make clear_huge_page cache clear only around the fault address
>    x86: switch the 64bit uncached page clear to SSE/AVX v2
>

This is a mix of x86-specific and generic changes... does anyone mind if 
I put this into the -tip tree?

	-hpa


-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
