Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9E4166B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 16:35:44 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so9408655pdi.0
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 13:35:44 -0700 (PDT)
Subject: [RFC][PATCH 0/8] mm: freshen percpu pageset code
From: Dave Hansen <dave@sr71.net>
Date: Tue, 15 Oct 2013 13:35:36 -0700
Message-Id: <20131015203536.1475C2BE@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Cody P Schafer <cody@linux.vnet.ibm.com>, Andi Kleen <ak@linux.intel.com>, cl@gentwo.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@sr71.net>

The percpu pageset (pcp) code is looking a little old and
neglected these days.  This set does a couple of these things (in
order of importance, not order of implementation in the series):

1. Change the default pageset pcp->high value from 744kB
   to 512k.  (see "consolidate high-to-batch ratio code")
2. Allow setting of vm.percpu_pagelist_fraction=0, which
   takes you back to the boot-time behavior
3. Resolve inconsistencies in the way the boot-time and
   sysctl pcp code works.
4. Clarify some function names and code comments.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
