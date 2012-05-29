Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id CC3436B005C
	for <linux-mm@kvack.org>; Tue, 29 May 2012 01:47:03 -0400 (EDT)
Date: Tue, 29 May 2012 15:46:56 +1000
From: Paul Mackerras <paulus@samba.org>
Subject: Re: Please include commit 90481622d7 in 3.3-stable
Message-ID: <20120529054656.GA17774@drongo>
References: <20120510095837.GB16271@bloggs.ozlabs.ibm.com>
 <1336811645.8274.496.camel@deadeye>
 <1338068260.20487.35.camel@deadeye>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1338068260.20487.35.camel@deadeye>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: Hillf Danton <dhillf@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Gibson <david@gibson.dropbear.id.au>, stable@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Sat, May 26, 2012 at 10:37:40PM +0100, Ben Hutchings wrote:
> On Sat, 2012-05-12 at 09:34 +0100, Ben Hutchings wrote:
> > I tried cherry-picking this on top of 3.2.17, but there was a conflict
> > in unmap_ref_private().  It looks like all of these belong in 3.2.y as
> > well:
> > 
> > 1e16a53 mm/hugetlb.c: fix virtual address handling in hugetlb fault
> > 0c176d5 mm: hugetlb: fix pgoff computation when unmapping page from vma
> > ea5768c mm/hugetlb.c: avoid bogus counter of surplus huge page
> > 409eb8c mm/hugetlb.c: undo change to page mapcount in fault handler
> > cd2934a flush_tlb_range() needs ->page_table_lock when ->mmap_sem is not held
> 
> Sorry, I didn't make myself clear.  I'm asking for confirmation: should
> these all be applied to 3.2.y?

I think yes, probably, but I'm not enough of an expert on the
hugetlbfs code to say for sure.  David Gibson is on leave at the
moment and so may not be in a position to reply.  Perhaps one of
hugetlbfs experts on cc could reply?

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
