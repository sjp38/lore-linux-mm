Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5ADD26B000D
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 22:11:59 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v10-v6so1928364pfm.11
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 19:11:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f8-v6sor821741plr.96.2018.07.03.19.11.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Jul 2018 19:11:58 -0700 (PDT)
Date: Wed, 4 Jul 2018 11:11:53 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH -mm -v4 00/21] mm, THP, swap: Swapout/swapin THP in one
 piece
Message-ID: <20180704021153.GA3346@jagdpanzerIV>
References: <20180622035151.6676-1-ying.huang@intel.com>
 <20180627215144.73e98b01099191da59bff28c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180627215144.73e98b01099191da59bff28c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>

On (06/27/18 21:51), Andrew Morton wrote:
> On Fri, 22 Jun 2018 11:51:30 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:
> 
> > This is the final step of THP (Transparent Huge Page) swap
> > optimization.  After the first and second step, the splitting huge
> > page is delayed from almost the first step of swapout to after swapout
> > has been finished.  In this step, we avoid splitting THP for swapout
> > and swapout/swapin the THP in one piece.
> 
> It's a tremendously good performance improvement.  It's also a
> tremendously large patchset :(

Will zswap gain a THP swap out/in support at some point?


mm/zswap.c: static int zswap_frontswap_store(...)
...
	/* THP isn't supported */
	if (PageTransHuge(page)) {
		ret = -EINVAL;
		goto reject;
	}

	-ss
