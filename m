Message-ID: <48ED0B68.2060001@linux-foundation.org>
Date: Wed, 08 Oct 2008 14:35:04 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] hugetlbfs: handle pages higher order than MAX_ORDER
References: <1223458431-12640-1-git-send-email-apw@shadowen.org> <1223458431-12640-2-git-send-email-apw@shadowen.org> <48ECDD37.8050506@linux-foundation.org> <20081008185532.GA13304@brain>
In-Reply-To: <20081008185532.GA13304@brain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jon Tollefson <kniht@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

Andy Whitcroft wrote:

> With SPARSEMEM turned on and VMEMMAP turned off a valid combination,
> we will end up scribbling all over memory which is pretty serious so for
> that reason we should handle this case.  There are cirtain combinations
> of features which require SPARSMEM but preclude VMEMMAP which trigger this.

Which configurations are we talking about? 64 bit configs may generally be
able to use VMEMMAP since they have lots of virtual address space.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
