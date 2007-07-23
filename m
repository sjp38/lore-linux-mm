Date: Mon, 23 Jul 2007 12:43:03 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/5] [hugetlb] Introduce BASE_PAGES_PER_HPAGE constant
Message-ID: <20070723124303.27b32989@schroedinger.engr.sgi.com>
In-Reply-To: <20070713151631.17750.44881.stgit@kernel>
References: <20070713151621.17750.58171.stgit@kernel>
	<20070713151631.17750.44881.stgit@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, William Lee Irwin III <wli@holomorphy.com>, Ken Chen <kenchen@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jul 2007 08:16:31 -0700
Adam Litke <agl@us.ibm.com> wrote:


> In many places throughout the kernel, the expression
> (HPAGE_SIZE/PAGE_SIZE) is used to convert quantities in huge page
> units to a number of base pages. Reduce redundancy and make the code
> more readable by introducing a constant BASE_PAGES_PER_HPAGE whose
> name more clearly conveys the intended conversion.

It may be better to put in a generic way of determining the pages of a
compound page.

Usually

1 << compound_order(page) will do the trick.

See also 

http://marc.info/?l=linux-kernel&m=118236495611300&w=2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
