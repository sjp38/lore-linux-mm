Date: Fri, 11 Nov 2005 13:23:51 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC] NUMA memory policy support for HUGE pages
Message-ID: <20051111212351.GT29402@holomorphy.com>
References: <Pine.LNX.4.62.0511111051080.20589@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0511111051080.20589@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, ak@suse.de, linux-kernel@vger.kernel.org, kenneth.w.chen@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, Nov 11, 2005 at 10:56:50AM -0800, Christoph Lameter wrote:
> Well since we got through respecting cpusets and allocating a page nearer 
> to the processors so easy lets go for the full thing. Here is a draft of 
> a patch that implements full NUMA policy support for it on top of the 
> cpusets and the NUMA near allocation patch.
> I am not sure that this is the right way to do it. Maybe we better put the 
> whole allocator into the policy layer like alloc_pages_vma?
> I needed to add two parameters to alloc_huge_page in order to get the 
> allocation right for all policy cases. This means that find_lock_page 
> has a plethora of parameters now. Maybe idx and the mapping could be 
> deduced from addr and vma?

I've been awash in good hugetlb patches lately, and here's another one.
I don't have any strong feelings about this (apart from the code quality
observation), so could someone who has an interest in mempolicy affairs
(Andi, Adam, et al) chime in and say this is the way people want to go?


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
