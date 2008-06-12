Date: Thu, 12 Jun 2008 09:08:12 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [patch 16/21] hugetlb: allow arch overried hugepage allocation
Message-ID: <20080612080812.GC30958@shadowen.org>
References: <20080604112939.789444496@amd.local0.net> <20080604113113.026345633@amd.local0.net> <20080608121445.168fb358.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080608121445.168fb358.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 08, 2008 at 12:14:45PM -0700, Andrew Morton wrote:
> On Wed, 04 Jun 2008 21:29:55 +1000 npiggin@suse.de wrote:
> 
> > Subject: [patch 16/21] hugetlb: allow arch overried hugepage allocation
> 
> I assumed that this was supposed to read "overridden".
> 
> >  
> > +__initdata LIST_HEAD(huge_boot_pages);
> 
> WARNING: externs should be avoided in .c files
> #61: FILE: mm/hugetlb.c:34:
> +__initdata LIST_HEAD(huge_boot_pages);
> 
> checkpatch got confused.

Yes, I caught that one too.  We stupidly convert a known modifier into a
type.  Sorted in my next block of changes.  Will be with you today I
hope.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
