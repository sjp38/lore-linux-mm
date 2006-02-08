Date: Wed, 8 Feb 2006 10:23:42 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Lhms-devel] [PATCH 4/9] ppc64 - Specify amount of kernel memory
 at boot time
In-Reply-To: <43E90BC1.7010907@austin.ibm.com>
Message-ID: <Pine.LNX.4.58.0602081022090.20544@skynet>
References: <20060126184305.8550.94358.sendpatchset@skynet.csn.ul.ie>
 <20060126184425.8550.64598.sendpatchset@skynet.csn.ul.ie>
 <43E90BC1.7010907@austin.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joel Schopp <jschopp@austin.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tue, 7 Feb 2006, Joel Schopp wrote:

> > This patch adds the kernelcore= parameter for ppc64
>
> ...
>
> > diff -rup -X /usr/src/patchset-0.6/bin//dontdiff
> > linux-2.6.16-rc1-mm3-103_x86coremem/mm/page_alloc.c
> > linux-2.6.16-rc1-mm3-104_ppc64coremem/mm/page_alloc.c
> > --- linux-2.6.16-rc1-mm3-103_x86coremem/mm/page_alloc.c      2006-01-26
> > 18:09:04.000000000 +0000
> > +++ linux-2.6.16-rc1-mm3-104_ppc64coremem/mm/page_alloc.c    2006-01-26
> > 18:10:29.000000000 +0000
>
> Not to nitpick, but this chunk should go in a different patch, it's not ppc64
> specific.
>

You're right. It was put in here because it was testing this patch on
ppc64 that the bug was revealed. It should be moved to the patch that adds
the actual zone.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
