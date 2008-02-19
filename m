Date: Tue, 19 Feb 2008 15:30:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hugetlb: ensure we do not reference a surplus page
 after handing it to buddy
Message-Id: <20080219153037.ec336fd2.akpm@linux-foundation.org>
In-Reply-To: <1203446512.11987.36.camel@localhost.localdomain>
References: <1203445688.0@pinky>
	<1203446512.11987.36.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Nishanth Aravamudan <nacc@us.ibm.com>, William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Feb 2008 12:41:51 -0600 Adam Litke <agl@us.ibm.com> wrote:

> Indeed.  I'll take credit for this thinko...
> 
> On Tue, 2008-02-19 at 18:28 +0000, Andy Whitcroft wrote:
> > When we free a page via free_huge_page and we detect that we are in
> > surplus the page will be returned to the buddy.  After this we no longer
> > own the page.  However at the end free_huge_page we clear out our mapping
> > pointer from page private.  Even where the page is not a surplus we
> > free the page to the hugepage pool, drop the pool locks and then clear
> > page private.  In either case the page may have been reallocated.  BAD.
> > 
> > Make sure we clear out page private before we free the page.
> > 
> > Signed-off-by: Andy Whitcroft <apw@shadowen.org>
> 
> Acked-by: Adam Litke <agl@us.ibm.com>

Was I right to assume that this is also needed in 2.6.24.x?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
