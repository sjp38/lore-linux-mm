Date: Wed, 14 May 2008 06:25:44 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 0/6] 16G and multi size hugetlb page support on powerpc
Message-ID: <20080514042544.GA23578@wotan.suse.de>
References: <4829CAC3.30900@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4829CAC3.30900@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kniht@linux.vnet.ibm.com
Cc: linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@ozlabs.org>, Paul Mackerras <paulus@samba.org>, Nishanth Aravamudan <nacc@us.ibm.com>, Andi Kleen <andi@firstfloor.org>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 13, 2008 at 12:07:15PM -0500, Jon Tollefson wrote:
> This patch set builds on Nick Piggin's patches for multi size and giant 
> hugetlb page support of April 22.  The following set of patches adds 
> support for 16G huge pages on ppc64 and support for multiple huge page 
> sizes at the same time on ppc64.  Thus allowing 64K, 16M, and 16G huge 
> pages given a POWER5+ or later machine.
> 
> New to this version of my patch is numerous bug fixes and cleanups, but 
> the biggest change is the support for multiple huge page sizes on power.
> 
> patch 1: changes to generic hugetlb to enable 16G pages on power
> patch 2: powerpc: adds function for allocating 16G pages
> patch 3: powerpc: setups 16G page locations found in device tree
> patch 4: powerpc: page definition support for 16G pages
> patch 5: check for overflow when user space is 32bit
> patch 6: powerpc: multiple huge page size support

Hi Jon,

Thanks very much. I'll put these at the end of my patchset and attempt
to keep them building if I make changes to the core code (have to spend
a bit of time catching up with the review comments from last round).

I'll send out another patchset for review in a day or so after I catch
up, and then hopefully get it merged in -mm for 2.6.27.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
