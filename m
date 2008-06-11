Date: Wed, 11 Jun 2008 13:52:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [v4][PATCH 2/2] fix large pages in pagemap
Message-Id: <20080611135207.32a46267.akpm@linux-foundation.org>
In-Reply-To: <1213216462.20475.36.camel@nimitz>
References: <20080611180228.12987026@kernel>
	<20080611180230.7459973B@kernel>
	<20080611123724.3a79ea61.akpm@linux-foundation.org>
	<1213213980.20045.116.camel@calx>
	<20080611131108.61389481.akpm@linux-foundation.org>
	<1213216462.20475.36.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: mpm@selenic.com, hans.rosenfeld@amd.com, linux-mm@kvack.org, hugh@veritas.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jun 2008 13:34:22 -0700
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Wed, 2008-06-11 at 13:11 -0700, Andrew Morton wrote:
> > Really?  There already a couple of pmd_huge() tests in mm/memory.c and
> > Rik's access_process_vm-device-memory-infrastructure.patch adds
> > another one.
> 
> We're not supposed to ever hit the one in follow_page() because there
> are:
> 
>                 if (is_vm_hugetlb_page(vma)) {
>                         i = follow_hugetlb_page(mm, vma, pages, vmas,
>                                                 &start, &len, i, write);
>                         continue;
>                 }
> 
> checks before them like in get_user_pages();
> 
> The other mm/memory.c call is under alloc_vm_area(), and that's
> supposedly only used on kernel addresses.  I don't think we even have
> Linux pagetables for kernel addresses on ppc.
> 

access_process_vm-device-memory-infrastructure.patch is a powerpc
feature, and it uses pmd_huge().

Am I missing something, or is pmd_huge() a whopping big grenade for x86
developers to toss at non-x86 architectures?  It seems quite dangerous.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
