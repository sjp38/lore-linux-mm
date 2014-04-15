Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 41D386B0055
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 14:52:22 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id rr13so9918802pbb.15
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 11:52:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id bi5si11343272pbb.105.2014.04.15.11.52.20
        for <linux-mm@kvack.org>;
        Tue, 15 Apr 2014 11:52:21 -0700 (PDT)
Date: Tue, 15 Apr 2014 11:52:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/4] mm: Clear VM_SOFTDIRTY flag inside clear_refs_write
 instead of clear_soft_dirty
Message-Id: <20140415115219.2676d2107b3f6b0dd5573062@linux-foundation.org>
In-Reply-To: <20140415184851.GS23983@moon>
References: <20140324122838.490106581@openvz.org>
	<20140324125926.204897920@openvz.org>
	<20140415110654.4dd9a97c216e2689316fa448@linux-foundation.org>
	<20140415182935.GR23983@moon>
	<20140415114449.c8732a56f9974c2819e4541a@linux-foundation.org>
	<20140415184851.GS23983@moon>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, xemul@parallels.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Tue, 15 Apr 2014 22:48:51 +0400 Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> On Tue, Apr 15, 2014 at 11:44:49AM -0700, Andrew Morton wrote:
> > On Tue, 15 Apr 2014 22:29:35 +0400 Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> > 
> > > On Tue, Apr 15, 2014 at 11:06:54AM -0700, Andrew Morton wrote:
> > > > 
> > > > I resolved this by merging
> > > > mm-softdirty-clear-vm_softdirty-flag-inside-clear_refs_write-instead-of-clear_soft_dirty.patch
> > > > on top of the pagewalk patches as below - please carefully review.
> > > 
> > > Thanks a lot, Andrew! I've updated the patches and were planning to send them to you
> > > tonightm but because you applied it on top of pagewal patches, I think i rather need to
> > > fetch -next repo and review this patch and update the rest of the series on top (hope
> > > i'll do that in 3-4 hours).
> > 
> > -mm isn't in -next at present.  I'll get a release done later today for
> > tomorrow's -next.
> 
> OK. Could you please remind me the place I could fetch the patchwalk series from?

http://ozlabs.org/~akpm/mmots/

> (or better to wait until -mm get merged into -next?)

That's probably simpler.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
