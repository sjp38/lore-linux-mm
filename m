Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 264216B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 21:00:30 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id ma3so5075021pbc.28
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 18:00:29 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id zn10si15426615pac.99.2014.06.16.18.00.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 18:00:29 -0700 (PDT)
Received: by mail-pa0-f41.google.com with SMTP id fb1so2614469pad.14
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 18:00:28 -0700 (PDT)
Date: Mon, 16 Jun 2014 17:59:07 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] hugetlb: fix copy_hugetlb_page_range() to handle
 migration/hwpoisoned entry
In-Reply-To: <20140616195950.GA21801@nhori.bos.redhat.com>
Message-ID: <alpine.LSU.2.11.1406161750520.1190@eggly.anvils>
References: <1402081620-1247-1-git-send-email-n-horiguchi@ah.jp.nec.com> <alpine.LSU.2.11.1406151642020.25482@eggly.anvils> <20140616195950.GA21801@nhori.bos.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 16 Jun 2014, Naoya Horiguchi wrote:
> On Sun, Jun 15, 2014 at 05:19:29PM -0700, Hugh Dickins wrote:
> > 
> > Hold on, that restriction of hugepage migration was marked for stable
> > 3.12+, whereas this is marked for stable 2.6.36+ (a glance at my old
> > trees suggests 2.6.37+, but you may know better - perhaps hugepage
> > migration got backported to 2.6.36-stable, though hardly seems
> > stable material).
> 
> Sorry, I misinterpreted one thing.
> I thought hugepage migration was merged at 2.6.36 because git-describe
> shows v2.6.36-rc7-73-g290408d4a2 for commit 290408d4a2 "hugetlb: hugepage
> migration core." But actually that's merged at commit f1ebdd60cc, or
> v2.6.36-5792-gf1ebdd60cc73. So this is 2.6.37 stuff.
> 
> Originally hugepage migration was used only for soft offlining in
> mm/memory-failure.c which is available only in x86_64, so we implicitly
> assumed that hugepage migration was restricted to x86_64.
> At 3.12, hugepage migration became available for numa APIs like mbind(),
> which are used for other architectures, so the restriction with
> hugepage_migration_supported() became necessary since then.
> This is the reason why the disablement was marked for 3.12+.
> This patch are helpful before extension in 3.12, so it should be marked 2.6.37+.

That all makes sense to me now: thanks a lot for explaining the history.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
