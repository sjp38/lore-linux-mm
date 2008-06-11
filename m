Date: Wed, 11 Jun 2008 12:37:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [v4][PATCH 2/2] fix large pages in pagemap
Message-Id: <20080611123724.3a79ea61.akpm@linux-foundation.org>
In-Reply-To: <20080611180230.7459973B@kernel>
References: <20080611180228.12987026@kernel>
	<20080611180230.7459973B@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: hans.rosenfeld@amd.com, mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jun 2008 11:02:31 -0700
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> 
> We were walking right into huge page areas in the pagemap
> walker, and calling the pmds pmd_bad() and clearing them.
> 
> That leaked huge pages.  Bad.
> 
> This patch at least works around that for now.  It ignores
> huge pages in the pagemap walker for the time being, and
> won't leak those pages.
> 

I don't get it.   Why can't we just stick a

	if (pmd_huge(pmd))
		continue;

into pagemap_pte_range()?  Or something like that.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
