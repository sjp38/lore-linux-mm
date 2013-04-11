Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id C1D256B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 10:47:13 -0400 (EDT)
Date: Thu, 11 Apr 2013 10:47:06 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1365691626-w2h428s2-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130411140012.GI16732@two.firstfloor.org>
References: <1365665524-nj0fhwkj-mutt-n-horiguchi@ah.jp.nec.com>
 <20130411140012.GI16732@two.firstfloor.org>
Subject: Re: [RFC Patch 2/2] mm: Add parameters to limit a rate of outputting
 memory error messages
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Mitsuhiro Tanino <mitsuhiro.tanino.gm@hitachi.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Thu, Apr 11, 2013 at 04:00:12PM +0200, Andi Kleen wrote:
> > I don't think it's enough to do ratelimit only for me_pagecache_dirty().
> > When tons of memory errors flood, all of printk()s in memory error handler
> > can print out tons of messages.
> 
> Note that when you really have a flood of uncorrected errors you'll
> likely die soon anyways as something unrecoverable is very likely to
> happen. Error memory recovery cannot fix large scale memory corruptions,
> just the rare events that slip through all the other memory error correction
> schemes.
> 
> So I wouldn't worry too much about that.

I agree.
My previous comment is valid only when we assume the flooding can happen
(and I personally don't believe that can happen except for in testing.)

And for paranoid users, we can suggest that they set up mcelog script
triggering to turn off vm.memory_failure_recovery when memory errors flood.
Such users don't expect that memory error handling works fine in flooding,
so just suppressing kernel messages is pointless.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
