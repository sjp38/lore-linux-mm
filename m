Date: Thu, 27 Oct 2005 10:14:59 +1000
From: 'David Gibson' <david@gibson.dropbear.id.au>
Subject: Re: RFC: Cleanup / small fixes to hugetlb fault handling
Message-ID: <20051027001459.GA16013@localhost.localdomain>
References: <20051026024831.GB17191@localhost.localdomain> <200510262012.j9QKCUg23575@unix-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200510262012.j9QKCUg23575@unix-os.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hugh@veritas.com, William Irwin <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 26, 2005 at 01:12:30PM -0700, Chen, Kenneth W wrote:
> David Gibson wrote on Tuesday, October 25, 2005 7:49 PM
> > - find_lock_huge_page() didn't, in fact, lock the page if it newly
> >   allocated one, rather than finding it in the page cache already.  As
> >   far as I can tell this is a bug, so the patch corrects it.
> 
> add_to_page_cache will lock the page if it was successfully added to the
> address space radix tree.  I don't see a bug that you are seeing.

Ah, so it does.  Thought I might be missing something.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/people/dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
