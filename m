Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A05A86B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 17:39:05 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id e9so458683579pgc.5
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 14:39:05 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a4si32953297pli.5.2016.11.29.14.39.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 14:39:04 -0800 (PST)
Date: Tue, 29 Nov 2016 14:39:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] z3fold fixes
Message-Id: <20161129143916.f24c141c1a264bad1220031e@linux-foundation.org>
In-Reply-To: <CALZtONCzseKs22189B3b+TEPKu8JPQ4WcGGB0zPj4KNuKiUAig@mail.gmail.com>
References: <20161126201534.5d5e338f678b478e7a7b8dc3@gmail.com>
	<CALZtONCzseKs22189B3b+TEPKu8JPQ4WcGGB0zPj4KNuKiUAig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Vitaly Wool <vitalywool@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Dan Carpenter <dan.carpenter@oracle.com>

On Tue, 29 Nov 2016 17:33:19 -0500 Dan Streetman <ddstreet@ieee.org> wrote:

> On Sat, Nov 26, 2016 at 2:15 PM, Vitaly Wool <vitalywool@gmail.com> wrote:
> > Here come 2 patches with z3fold fixes for chunks counting and locking. As commit 50a50d2 ("z3fold: don't fail kernel build is z3fold_header is too big") was NAK'ed [1], I would suggest that we removed that one and the next z3fold commit cc1e9c8 ("z3fold: discourage use of pages that weren't compacted") and applied the coming 2 instead.
> 
> Instead of adding these onto all the previous ones, could you redo the
> entire z3fold series?  I think it'll be simpler to review the series
> all at once and that would remove some of the stuff from previous
> patches that shouldn't be there.
> 
> If that's ok with Andrew, of course, but I don't think any of the
> z3fold patches have been pushed to Linus yet.

Sounds good to me.  I had a few surprise rejects when merging these
two, which indicates that things might be out of sync.

I presently have:

z3fold-limit-first_num-to-the-actual-range-of-possible-buddy-indexes.patch
z3fold-make-pages_nr-atomic.patch
z3fold-extend-compaction-function.patch
z3fold-use-per-page-spinlock.patch
z3fold-discourage-use-of-pages-that-werent-compacted.patch
z3fold-fix-header-size-related-issues.patch
z3fold-fix-locking-issues.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
