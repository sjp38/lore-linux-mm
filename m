Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4C9526B01F2
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 17:26:19 -0400 (EDT)
Date: Thu, 19 Aug 2010 05:26:13 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [TESTCASE] Clean pages clogging the VM
Message-ID: <20100818212613.GA7366@localhost>
References: <20100809133000.GB6981@wil.cx>
 <20100817195001.GA18817@linux.intel.com>
 <20100818141308.GD1779@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100818141308.GD1779@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Shaohua <shaohua.li@intel.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> Mapped file pages get two rounds on the LRU list, so once the VM
> starts scanning, it has to go through all of them twice and can only
> reclaim them on the second encounter.

This can be fixed gracefully based on Rik's refault-distance patch :)
With the distance info we can safely drop the use-once mapped file pages.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
