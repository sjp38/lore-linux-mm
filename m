Received: from vega.wipinfo.soft.net (root@vega [192.168.223.136])
	by patriot.wipinfo.soft.net (8.9.2/8.9.2) with ESMTP id NAA23949
	for <linux-mm@kvack.org>; Tue, 15 Jun 1999 13:34:05 -0500 (GMT)
Received: from prashanth (unknown_cad183 [192.168.224.183]) by wipinfo.soft.net (8.6.12/8.6.9) with SMTP id NAA30558 for <linux-mm@kvack.org>; Tue, 15 Jun 1999 13:16:31 +0500
Reply-To: <cprash@wipinfo.soft.net>
From: "Prashanth C." <cprash@wipinfo.soft.net>
Subject: kmem_cache_init() question
Date: Tue, 15 Jun 1999 13:39:12 +0530
Message-ID: <000001beb706$5a8b06a0$b7e0a8c0@prashanth.wipinfo.soft.net>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi All,

This question is with reference to following segment of code [ver 2.2.9] in
kmem_cache_init() function (mm/slab.c):

if (num_physpages > (32 << 20) >> PAGE_SHIFT)
    slab_break_gfp_order = SLAB_BREAK_GFP_ORDER_HI;

I found that num_physpages is initialized in mem_init() function
(arch/i386/mm/init.c).  But start_kernel() calls kmem_cache_init() before
mem_init().  So, num_physpages will always(?) be zero when the above code
segment is executed.

Is num_physpages is initialized somewhere else before kmem_cache_init() is
called by start_kernel()?  Please let me know if I am missing something [if
my observation is indeed correct, then slab_break_gfp_order will never be
set to SLAB_BREAK_GFP_ORDER_HI].

Thanks a lot.

Prashanth.

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
