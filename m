Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id BEC826B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 12:23:17 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id n12so5308040wgh.17
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 09:23:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ys3si26417120wjc.16.2014.06.02.09.23.09
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 09:23:10 -0700 (PDT)
Message-ID: <538ca4ee.43f9c20a.7b91.2020SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/3] mm: introduce fincore()
Date: Mon,  2 Jun 2014 12:22:34 -0400
In-Reply-To: <538CA239.3060506@intel.com>
References: <20140521193336.5df90456.akpm@linux-foundation.org> <1401686699-9723-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1401686699-9723-3-git-send-email-n-horiguchi@ah.jp.nec.com> <538CA239.3060506@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hello Dave,

On Mon, Jun 02, 2014 at 09:11:37AM -0700, Dave Hansen wrote:
> On 06/01/2014 10:24 PM, Naoya Horiguchi wrote:
> > Detail about the data format being passed to userspace are explained in
> > inline comment, but generally in long entry format, we can choose which
> > information is extraced flexibly, so you don't have to waste memory by
> > extracting unnecessary information. And with FINCORE_SKIP_HOLE flag,
> > we can skip hole pages (not on memory,) which makes us avoid a flood of
> > meaningless zero entries when calling on extremely large (but only few
> > pages of it are loaded on memory) file.
> 
> Something similar could be useful for hugetlbfs too.  For a 1GB page,
> it's pretty silly to do 2^18 entries which essentially repeat the same
> data in an interface like this.

Good point.
For hugetlbfs file, we link a hugepage to pagecache at the index of
"hugepage" offset, so the second 1GB page in a hugetlbfs file are
linked to index 1, not 2^18. Current version of fincore() already
handle hugepage properly, so meaningless data copy doesn't happen.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
