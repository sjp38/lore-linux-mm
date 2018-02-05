Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6D1C16B0007
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 00:29:33 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id a61so10535073pla.22
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 21:29:33 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id z12si5110142pgs.167.2018.02.04.21.29.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Feb 2018 21:29:32 -0800 (PST)
Date: Mon, 5 Feb 2018 13:30:13 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: RFC: eliminate zone->lock contention for will-it-scale/page_fault1
 on big server
Message-ID: <20180205053013.GB16980@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180124023050.20097-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Daniel Jordan <daniel.m.jordan@oracle.com>

In addition the the two patches, there are two more patches that I would
like to get some feedback.

The two patches are more radical: the 3rd deals with free path
zone->lock contention by avoiding doing any merge for order0 pages while
the 4th deals with allocation path zone->lock contention by taking
pcp->batch pages off the free_area order0 list without the need to
iterate the list.

Both patches are developed based on "the most time consuming part of
operations under zone->lock is cache misses on struct page".

The 3rd patch may be controversial but doesn't have correctness problem;
the 4th is in an early stage and serves only as a proof-of-concept.

Your comments are appreciated, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
