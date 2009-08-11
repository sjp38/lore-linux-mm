Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 161046B004F
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 09:00:20 -0400 (EDT)
Date: Tue, 11 Aug 2009 20:38:19 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [16/19] HWPOISON: Enable .remove_error_page for
	migration    aware file systems
Message-ID: <20090811123819.GB18881@localhost>
References: <200908051136.682859934@firstfloor.org> <20090805093643.E0C00B15D8@basil.firstfloor.org> <4A7FBFD1.2010208@hitachi.com> <20090810070745.GA26533@localhost> <4A80EA14.4030300@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A80EA14.4030300@hitachi.com>
Sender: owner-linux-mm@kvack.org
To: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
Cc: Andi Kleen <andi@firstfloor.org>, "tytso@mit.edu" <tytso@mit.edu>, "hch@infradead.org" <hch@infradead.org>, "mfasheh@suse.com" <mfasheh@suse.com>, "aia21@cantab.net" <aia21@cantab.net>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "swhiteho@redhat.com" <swhiteho@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "npiggin@suse.de" <npiggin@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>, Taketoshi Sakuraba <taketoshi.sakuraba.hc@hitachi.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 11, 2009 at 11:48:36AM +0800, Hidehiro Kawai wrote:
> Wu Fengguang wrote:
> > In fact we proposed a patch for preventing the re-corruption case, see
> > 
> >         http://lkml.org/lkml/2009/6/11/294
> > 
> > However it is hard to answer the (policy) question "How sticky should
> > the EIO bit remain?".
> 
> It's a good approach!  This approach may also solve my concern,
> the re-corruption issue caused by transient IO errors.
> 
> But I also think it needs a bit more consideration.  For example,
> if the application has the valid data in the user space buffer,
> it would try to re-write it after detecting an IO error from the
> previous write.  In this case, we should clear the sticky error flag.

Yes, and maybe more than that. The IO error issue really deserves an
independent work, which will inevitably involve lots of discussions
with lots of people.

For the data re-corruption problem, "vm.memory_failure_recovery = 0"
should be the most clean workaround for now. Can we settle with that?
Our goal for this initial hwpoison implementation is to achieve good
coverage (not necessarily every possible case :).

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
