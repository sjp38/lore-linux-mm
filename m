Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9CF466B0031
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 18:07:10 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id p10so4079487pdj.9
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 15:07:10 -0800 (PST)
Received: from psmtp.com ([74.125.245.129])
        by mx.google.com with SMTP id hi3si3220276pbb.123.2013.11.15.15.07.07
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 15:07:08 -0800 (PST)
Subject: [v3][PATCH 0/2] v3: fix hugetlb vs. anon-thp copy page
From: Dave Hansen <dave@sr71.net>
Date: Fri, 15 Nov 2013 14:55:50 -0800
Message-Id: <20131115225550.737E5C33@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, dave.jiang@intel.com, akpm@linux-foundation.org, dhillf@gmail.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Dave Hansen <dave@sr71.net>

This took some of Mel's comments in to consideration.  Dave
Jiang, could you retest this if you get a chance?  These have
only been lightly compile-tested.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
