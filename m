Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id C9A336B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 10:00:14 -0400 (EDT)
Date: Thu, 11 Apr 2013 16:00:12 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC Patch 2/2] mm: Add parameters to limit a rate of
 outputting memory error messages
Message-ID: <20130411140012.GI16732@two.firstfloor.org>
References: <1365665524-nj0fhwkj-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365665524-nj0fhwkj-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mitsuhiro Tanino <mitsuhiro.tanino.gm@hitachi.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

> I don't think it's enough to do ratelimit only for me_pagecache_dirty().
> When tons of memory errors flood, all of printk()s in memory error handler
> can print out tons of messages.

Note that when you really have a flood of uncorrected errors you'll
likely die soon anyways as something unrecoverable is very likely to
happen. Error memory recovery cannot fix large scale memory corruptions,
just the rare events that slip through all the other memory error correction
schemes.

So I wouldn't worry too much about that.

The flooding problem is typically more with corrected error reporting.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
