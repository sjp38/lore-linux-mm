Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1E36B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 12:22:08 -0400 (EDT)
Received: by mail-qg0-f52.google.com with SMTP id a108so13390208qge.39
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 09:22:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id fo10si22679860qcb.35.2014.06.03.09.22.06
        for <linux-mm@kvack.org>;
        Tue, 03 Jun 2014 09:22:07 -0700 (PDT)
Message-ID: <538df62f.0acde50a.3a1b.7febSMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH -mm] mincore: apply page table walker on do_mincore() (Re: [PATCH 00/10] mm: pagewalk: huge page cleanups and VMA passing)
Date: Tue,  3 Jun 2014 12:22:01 -0400
In-Reply-To: <538DF0F1.5070104@sr71.net>
References: <20140602213644.925A26D0@viggo.jf.intel.com> <1401745925-l651h3s9@n-horiguchi@ah.jp.nec.com> <538CF25E.8070905@sr71.net> <1401776292-dn0fof8e@n-horiguchi@ah.jp.nec.com> <538DF0F1.5070104@sr71.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Jun 03, 2014 at 08:59:45AM -0700, Dave Hansen wrote:
> On 06/02/2014 11:18 PM, Naoya Horiguchi wrote:
> > +	/*
> > +	 * Huge pages are always in RAM for now, but
> > +	 * theoretically it needs to be checked.
> > +	 */
> > +	present = pte && !huge_pte_none(huge_ptep_get(pte));
> > +	for (; addr != end; vec++, addr += PAGE_SIZE)
> > +		*vec = present;
> > +	cond_resched();
> > +	walk->private += (end - addr) >> PAGE_SHIFT;
> 
> That comment is bogus, fwiw.  Huge pages are demand-faulted and it's
> quite possible that they are not present.

No. hugetlbfs adopts prefault mechanism, which creates free hugepage
pool in advance and hugepage allocation is done from the pool,
The above comment claims this. But if we want to comment more precisely,
it should be like "Hugepages under user process are always in RAM and
never swapped out, but ...".

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
