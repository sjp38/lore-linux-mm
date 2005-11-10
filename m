Date: Wed, 9 Nov 2005 16:15:34 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 4/4] Hugetlb: Copy on Write support
Message-ID: <20051110001534.GN29402@holomorphy.com>
References: <1131578925.28383.9.camel@localhost.localdomain> <1131579596.28383.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1131579596.28383.25.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Gibson <david@gibson.dropbear.id.au>, hugh@veritas.com, rohit.seth@intel.com, kenneth.w.chen@intel.com
List-ID: <linux-mm.kvack.org>

On Wed, Nov 09, 2005 at 05:39:55PM -0600, Adam Litke wrote:
> Hugetlb: Copy on Write support
> Implement copy-on-write support for hugetlb mappings so MAP_PRIVATE can be
> supported.  This helps us to safely use hugetlb pages in many more
> applications.  The patch makes the following changes.  If needed, I also have
> it broken out according to the following paragraphs.
> 1. Add a pair of functions to set/clear write access on huge ptes.  The
> writable check in make_huge_pte is moved out to the caller for use by COW
> later.
> 2. Hugetlb copy-on-write requires special case handling in the following
> situations:
>  - copy_hugetlb_page_range() - Copied pages must be write protected so a COW
>     fault will be triggered (if necessary) if those pages are written to.
>  - find_or_alloc_huge_page() - Only MAP_SHARED pages are added to the page
>     cache.  MAP_PRIVATE pages still need to be locked however.
> 3. Provide hugetlb_cow() and calls from hugetlb_fault() and hugetlb_no_page()
> which handles the COW fault by making the actual copy.
> 4. Remove the check in hugetlbfs_file_map() so that MAP_PRIVATE mmaps will be
> allowed.  Make MAP_HUGETLB exempt from the depricated VM_RESERVED mapping
> check.

Did you do the audit of pte protection bits I asked about? If not, I'll
dredge them up and check to make sure.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
