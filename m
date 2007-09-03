Date: Mon, 3 Sep 2007 07:32:19 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [RFC][PATCH 7/9] pagewalk: add handler for empty ranges
Message-ID: <20070903123219.GR21720@waste.org>
References: <20070821204248.0F506A29@kernel> <20070821204256.140D32D2@kernel> <46D67182.8080408@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46D67182.8080408@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 30, 2007 at 05:28:02PM +1000, Nick Piggin wrote:
> Dave Hansen wrote:
> 
> >@@ -27,25 +23,23 @@ static int walk_pmd_range(pud_t *pud, un
> > {
> > 	pmd_t *pmd;
> > 	unsigned long next;
> >-	int err;
> >+	int err = 0;
> > 
> > 	for (pmd = pmd_offset(pud, addr); addr != end;
> > 	     pmd++, addr = next) {
> > 		next = pmd_addr_end(addr, end);
> 
> While you're there, do you mind fixing the actual page table walking so
> that it follows the normal form?

Already done in my local series.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
