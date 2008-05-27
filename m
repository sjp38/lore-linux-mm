Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4RHE52f028973
	for <linux-mm@kvack.org>; Tue, 27 May 2008 13:14:05 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RHE6qm100034
	for <linux-mm@kvack.org>; Tue, 27 May 2008 13:14:06 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RHE5VA009492
	for <linux-mm@kvack.org>; Tue, 27 May 2008 13:14:05 -0400
Date: Tue, 27 May 2008 10:14:03 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 23/23] powerpc: support multiple hugepage sizes
Message-ID: <20080527171403.GI20709@us.ibm.com>
References: <20080525142317.965503000@nick.local0.net> <20080525143454.559452000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080525143454.559452000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Jon Tollefson <kniht@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On 26.05.2008 [00:23:40 +1000], npiggin@suse.de wrote:
> Instead of using the variable mmu_huge_psize to keep track of the huge
> page size we use an array of MMU_PAGE_* values.  For each supported
> huge page size we need to know the hugepte_shift value and have a
> pgtable_cache.  The hstate or an mmu_huge_psizes index is passed to
> functions so that they know which huge page size they should use.
> 
> The hugepage sizes 16M and 64K are setup(if available on the
> hardware) so that they don't have to be set on the boot cmd line in
> order to use them.  The number of 16G pages have to be specified at
> boot-time though (e.g. hugepagesz=16G hugepages=5).

This patch probably should updated Documentation as well, to indicate
power can also specify hugepagesz multiple times?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
