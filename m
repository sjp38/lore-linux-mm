Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3F0D36B0037
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 18:34:03 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id lf10so2749039pab.8
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 15:34:02 -0800 (PST)
Received: from psmtp.com ([74.125.245.196])
        by mx.google.com with SMTP id cx4si84936pbc.359.2013.11.14.15.33.59
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 15:33:59 -0800 (PST)
Subject: [PATCH 0/2] v2: fix hugetlb vs. anon-thp copy page
From: Dave Hansen <dave@sr71.net>
Date: Thu, 14 Nov 2013 15:33:57 -0800
Message-Id: <20131114233357.90EE35C1@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.jiang@intel.com, Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, dhillf@gmail.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Dave Hansen <dave@sr71.net>

There were only minor comments about this the last time around.
Any reason not not merge it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
