Subject: Re: [PATCH 1/1] hugetlbfs: handle pages higher order than MAX_ORDER
From: Andi Kleen <andi@firstfloor.org>
References: <1223458431-12640-1-git-send-email-apw@shadowen.org>
	<1223458431-12640-2-git-send-email-apw@shadowen.org>
	<48ECDD37.8050506@linux-foundation.org>
Date: Wed, 08 Oct 2008 19:36:10 +0200
In-Reply-To: <48ECDD37.8050506@linux-foundation.org> (Christoph Lameter's message of "Wed, 08 Oct 2008 11:17:59 -0500")
Message-ID: <87ej2rt2et.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jon Tollefson <kniht@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

Christoph Lameter <cl@linux-foundation.org> writes:
>
> But the memmap is contiguous in most cases. FLATMEM, VMEMMAP etc. Its only
> some special sparsemem configurations that couldhave the issue because they
> break up the vmemmap. x86_64 uses VMEMMAP by default. Is this for i386?

i386 doesn't support huge pages > MAX_ORDER. I guess it's for ppc64,
but they should probably just use vmemmap there if they don't already.

-Andi
-- 
ak@linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
