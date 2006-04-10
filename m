Date: Mon, 10 Apr 2006 14:05:18 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [RFC/PATCH] Shared Page Tables [1/2]
Message-ID: <C7A8E6F316A73810A5FF466E@[10.1.1.4]>
In-Reply-To: <1144695296.31255.16.camel@localhost.localdomain>
References: <1144685591.570.36.camel@wildcat.int.mccr.org>
 <1144695296.31255.16.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--On Monday, April 10, 2006 11:54:56 -0700 Dave Hansen
<haveblue@us.ibm.com> wrote:

>> Complete the macro definitions for pxd_page/pxd_page_kernel 
> 
> Could you explain a bit why these are needed for shared page tables?

The existing definitions define pte_page and pmd_page to return the struct
page for the pfn contained in that entry, and pmd_page_kernel returns the
kernel virtual address of it.  However, pud_page and pgd_page are defined
to return the kernel virtual address.  There are no macros that return the
struct page.

No one actually uses any of the pud_page and pgd_page macros (other than
one reference in the same include file).  After some discussion on the list
the last time I posted the patches, we agreed that changing pud_page and
pgd_page to be consistent with pmd_page is the best solution.  We also
agreed that I should go ahead and propagate that change across all
architectures even though not all of them currently support shared page
tables.  This patch is the result of that work.

Dave McCracken



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
