Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 62F5C681010
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 14:34:08 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 145so34483912pfv.6
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 11:34:08 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id s21si7800931pgh.403.2017.02.16.11.34.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 11:34:07 -0800 (PST)
Message-ID: <1487273646.2833.100.camel@linux.intel.com>
Subject: Re: swap_cluster_info lockdep splat
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Thu, 16 Feb 2017 11:34:06 -0800
In-Reply-To: <alpine.LSU.2.11.1702161050540.21773@eggly.anvils>
References: <20170216052218.GA13908@bbox>
	 <87o9y2a5ji.fsf@yhuang-dev.intel.com>
	 <alpine.LSU.2.11.1702161050540.21773@eggly.anvils>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, "Huang, Ying" <ying.huang@intel.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


> I do not understand your zest for putting wrappers around every little
> thing, making it all harder to follow than it need be.A  Here's the patch
> I've been running with (but you have a leak somewhere, and I don't have
> time to search out and fix it: please try sustained swapping and swapoff).
> 

Hugh, trying to duplicate your test case. A So you were doing swapping,
then swap off, swap on the swap device and restart swapping?

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
