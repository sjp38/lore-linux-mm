Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7BC3A6B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 17:52:30 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id dc16so3645516qab.28
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 14:52:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id a9si19998078qaj.70.2014.06.02.14.52.29
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 14:52:29 -0700 (PDT)
Message-ID: <538cf21d.c945e00a.16e5.ffff85adSMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 00/10] mm: pagewalk: huge page cleanups and VMA passing
Date: Mon,  2 Jun 2014 17:52:06 -0400
In-Reply-To: <20140602213644.925A26D0@viggo.jf.intel.com>
References: <20140602213644.925A26D0@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hello Dave,

On Mon, Jun 02, 2014 at 02:36:44PM -0700, Dave Hansen wrote:
> The hugetlbfs and THP support in the walk_page_range() code was
> mostly an afterthought.
> 
> We also _tried_ to have the pagewalk code be concerned only with
> page tables and *NOT* VMAs.  We lost that battle since 80% of
> the page walkers just pass the VMA along anyway.
> 
> This does a few cleanups and adds a new flavor of walker which
> can be stupid^Wsimple and not have to be explicitly taught about
> THP.

What version is this patchset based on?
Recently I comprehensively rewrote page table walker (from the same motivation
as yours) and the patchset is now in linux-mm. I guess most of your patchset
(I've not read them yet) conflict with this patchset.
So could you take a look on it?

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
