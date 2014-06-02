Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 904976B0037
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 17:36:50 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id fb1so1572877pad.35
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 14:36:50 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id xp2si17357178pbc.57.2014.06.02.14.36.49
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 14:36:49 -0700 (PDT)
Subject: [PATCH 00/10] mm: pagewalk: huge page cleanups and VMA passing
From: Dave Hansen <dave@sr71.net>
Date: Mon, 02 Jun 2014 14:36:44 -0700
Message-Id: <20140602213644.925A26D0@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Dave Hansen <dave@sr71.net>

The hugetlbfs and THP support in the walk_page_range() code was
mostly an afterthought.

We also _tried_ to have the pagewalk code be concerned only with
page tables and *NOT* VMAs.  We lost that battle since 80% of
the page walkers just pass the VMA along anyway.

This does a few cleanups and adds a new flavor of walker which
can be stupid^Wsimple and not have to be explicitly taught about
THP.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
