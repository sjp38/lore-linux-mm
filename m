Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DAE036B004F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 04:46:13 -0400 (EDT)
Date: Wed, 12 Aug 2009 10:46:13 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [16/19] HWPOISON: Enable .remove_error_page for migration aware file systems
Message-ID: <20090812084613.GB32342@wotan.suse.de>
References: <200908051136.682859934@firstfloor.org> <20090805093643.E0C00B15D8@basil.firstfloor.org> <4A7FBFD1.2010208@hitachi.com> <20090810074421.GA6838@basil.fritz.box> <4A80EAA3.7040107@hitachi.com> <20090811071756.GC14368@basil.fritz.box> <20090812080540.GA32342@wotan.suse.de> <20090812082331.GD28848@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090812082331.GD28848@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>, tytso@mit.edu, hch@infradead.org, mfasheh@suse.com, aia21@cantab.net, hugh.dickins@tiscali.co.uk, swhiteho@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>, Taketoshi Sakuraba <taketoshi.sakuraba.hc@hitachi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 12, 2009 at 10:23:31AM +0200, Andi Kleen wrote:
> > page corruption, IMO, because by definition they should be able to
> > tolerate panic. But if they do not know about this change to -EIO
> > semantics, then it is quite possible to cause problems.
> 
> There's no change really. You already have this problem with
> any metadata error, which can cause similar trouble.
> If the application handles those correctly it will also 
> handle hwpoison correctly.

What do you mean metadata error?

To be clear, we're talking about safety given by a panic on any
memory error, versus safety of this hwpoison code (specifically
which removes dirty pagecache pages as -EIO).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
