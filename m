Date: Fri, 13 Jun 2008 14:46:29 +0100
From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [RFC PATCH 0/2] Merge HUGETLB_PAGE and HUGETLBFS Kconfig
	options
Message-ID: <20080613134629.GD16344@linux-mips.org>
References: <1213296540.17108.8.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1213296540.17108.8.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, npiggin@suse.de, nacc@us.ibm.com, mel@csn.ul.ie, Eric B Munson <ebmunson@us.ibm.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, sparclinux@vger.kernel.org, linux-sh@vger.kernel.org, linux-s390@vger.kernel.org, linux-mips@linux-mips.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 12, 2008 at 02:49:00PM -0400, Adam Litke wrote:

> There are currently two global Kconfig options that enable/disable the
> hugetlb code: CONFIG_HUGETLB_PAGE and CONFIG_HUGETLBFS.  This may have
> made sense before hugetlbfs became ubiquitous but now the pair of
> options are redundant.  Merging these two options into one will simplify
> the code slightly and will, more importantly, avoid confusion and
> questions like: Which hugetlbfs CONFIG option should my code depend on?
> 
> CONFIG_HUGETLB_PAGE is aliased to the value of CONFIG_HUGETLBFS, so one
> option can be removed without any effect.  The first patch merges the
> two options into one option: CONFIG_HUGETLB.  The second patch updates
> the defconfigs to set the one new option appropriately.
> 
> I have cross-compiled this on i386, x86_64, ia64, powerpc, sparc64 and
> sh with the option enabled and disabled.  This is completely mechanical
> but, due to the large number of files affected (especially defconfigs),
> could do well with a review from several sets of eyeballs.  Thanks.

MIPS doesn't do HUGETLB (at least not in-tree atm) so I'm not sure why
linux-mips@linux-mips.org was cc'ed at all.  So feel free to add my
Couldnt-care-less: ack line ;-)

  Ralf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
