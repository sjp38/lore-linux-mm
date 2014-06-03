Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id EA3226B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 16:08:14 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id cm18so5807083qab.11
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 13:08:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 110si446067qgv.9.2014.06.03.13.08.14
        for <linux-mm@kvack.org>;
        Tue, 03 Jun 2014 13:08:14 -0700 (PDT)
Message-ID: <538e2b2e.f71a8c0a.39c7.ffffaa98SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH -mm] mincore: apply page table walker on do_mincore() (Re: [PATCH 00/10] mm: pagewalk: huge page cleanups and VMA passing)
Date: Tue,  3 Jun 2014 16:08:08 -0400
In-Reply-To: <538e2996.cd7ae00a.1e64.6067SMTPIN_ADDED_BROKEN@mx.google.com>
References: <20140602213644.925A26D0@viggo.jf.intel.com> <1401745925-l651h3s9@n-horiguchi@ah.jp.nec.com> <538CF25E.8070905@sr71.net> <1401776292-dn0fof8e@n-horiguchi@ah.jp.nec.com> <538DEFD8.4050506@intel.com> <538e2996.cd7ae00a.1e64.6067SMTPIN_ADDED_BROKEN@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Sorry, I've dropped one important word :(

On Tue, Jun 03, 2014 at 04:01:17PM -0400, Naoya Horiguchi wrote:
...
> > I'd argue that they don't really ever need to actually know at which
> > level they are in the page tables, just if they are at the bottom or
> > not.  Note that *NOBODY* sets a pud or pgd entry.  That's because the
> > walkers are 100% concerned about leaf nodes (pte's) at this point.
> 
> Yes. BTW do you think we should pud_entry() and pgd_entry() immediately?
                                 ^remove

> We can do it and it reduces some trivial evaluations, so it's optimized
> a little.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
