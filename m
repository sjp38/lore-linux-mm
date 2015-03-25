Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id DE21E6B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 19:09:48 -0400 (EDT)
Received: by pacwe9 with SMTP id we9so43666479pac.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 16:09:48 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com. [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id gl5si5659017pbc.6.2015.03.25.16.09.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 16:09:48 -0700 (PDT)
Received: by pdbcz9 with SMTP id cz9so43016896pdb.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 16:09:47 -0700 (PDT)
Date: Wed, 25 Mar 2015 16:09:38 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: avoid tail page refcounting on non-THP compound
 pages
In-Reply-To: <20150325225633.GA14549@node.dhcp.inet.fi>
Message-ID: <alpine.LSU.2.11.1503251602570.4703@eggly.anvils>
References: <1427323275-114866-1-git-send-email-kirill.shutemov@linux.intel.com> <alpine.LSU.2.11.1503251544120.4490@eggly.anvils> <alpine.LSU.2.11.1503251545510.4490@eggly.anvils> <20150325225633.GA14549@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 26 Mar 2015, Kirill A. Shutemov wrote:
> On Wed, Mar 25, 2015 at 03:48:48PM -0700, Hugh Dickins wrote:
> > On Wed, 25 Mar 2015, Hugh Dickins wrote:
> > > On Thu, 26 Mar 2015, Kirill A. Shutemov wrote:
> > > > 
> > > > Since currently all THP pages are anonymous and all drivers pages are
> > > > not, we can fix the __compound_tail_refcounted() check by requiring
> > > > PageAnon() to enable tail page refcounting.
> > > > 
> > > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > 
> > > Acked-by: Hugh Dickins <hughd@google.com>
> > 
> > Oh, hold on a moment: does this actually build in a tree without your
> > page-flags.h consolidation?  It didn't when I tried to add a PageAnon
> > test there for my series against v3.19, has something changed in v4.0?
> 
> No. I haven't tried to build it without my patchset, but it seems it
> wouldn't.
> 
> Just check: it would build for me on top of [PATCH 01/16], you've acked.

Yes, I'm happy with your 1/16 (which is already there in mmotm),
it's just that I'd imagined this __compound_tail_refcounted() fix
should go to v4.0 (if not stable too: you've decided against, okay).

What do you think, should Andrew hold it back for v4.1, or should
your page-flags.h accelerate into v4.0 as precondition for this fix?

Either is fine with me; but if the latter, then a week's exposure
in linux-next first would probably be best.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
