Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B44998D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:52:19 -0500 (EST)
Date: Mon, 7 Mar 2011 14:51:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hugetlb: /proc/meminfo shows data for all sizes of
 hugepages
Message-Id: <20110307145149.97e6676e.akpm@linux-foundation.org>
In-Reply-To: <1299527214.8493.13263.camel@nimitz>
References: <1299503155-6210-1-git-send-email-pholasek@redhat.com>
	<1299527214.8493.13263.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Petr Holasek <pholasek@redhat.com>, linux-kernel@vger.kernel.org, emunson@mgebm.net, anton@redhat.com, Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org

On Mon, 07 Mar 2011 11:46:54 -0800
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Mon, 2011-03-07 at 14:05 +0100, Petr Holasek wrote:
> > +       for_each_hstate(h)
> > +               seq_printf(m,
> > +                               "HugePages_Total:   %5lu\n"
> > +                               "HugePages_Free:    %5lu\n"
> > +                               "HugePages_Rsvd:    %5lu\n"
> > +                               "HugePages_Surp:    %5lu\n"
> > +                               "Hugepagesize:   %8lu kB\n",
> > +                               h->nr_huge_pages,
> > +                               h->free_huge_pages,
> > +                               h->resv_huge_pages,
> > +                               h->surplus_huge_pages,
> > +                               1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
> >  }
> 
> It sounds like now we'll get a meminfo that looks like:
> 
> ...
> AnonHugePages:    491520 kB
> HugePages_Total:       5
> HugePages_Free:        2
> HugePages_Rsvd:        3
> HugePages_Surp:        1
> Hugepagesize:       2048 kB
> HugePages_Total:       2
> HugePages_Free:        1
> HugePages_Rsvd:        1
> HugePages_Surp:        1
> Hugepagesize:    1048576 kB
> DirectMap4k:       12160 kB
> DirectMap2M:     2082816 kB
> DirectMap1G:     2097152 kB
> 
> At best, that's a bit confusing.  There aren't any other entries in
> meminfo that occur more than once.  Plus, this information is available
> in the sysfs interface.  Why isn't that sufficient?
> 
> Could we do something where we keep the default hpage_size looking like
> it does now, but append the size explicitly for the new entries?
> 
> HugePages_Total(1G):       2
> HugePages_Free(1G):        1
> HugePages_Rsvd(1G):        1
> HugePages_Surp(1G):        1
> 

Let's not change the existing interface, please.

Adding new fields: OK.
Changing the way in whcih existing fields are calculated: OKish.
Renaming existing fields: not OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
