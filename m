Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 37C736B005A
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 14:48:56 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id 10so7162708lbg.21
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 11:48:55 -0700 (PDT)
Received: from mail-la0-x22f.google.com (mail-la0-x22f.google.com [2a00:1450:4010:c03::22f])
        by mx.google.com with ESMTPS id pr4si13628080lbc.135.2014.04.15.11.48.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 11:48:54 -0700 (PDT)
Received: by mail-la0-f47.google.com with SMTP id pn19so7154445lab.6
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 11:48:53 -0700 (PDT)
Date: Tue, 15 Apr 2014 22:48:51 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 4/4] mm: Clear VM_SOFTDIRTY flag inside clear_refs_write
 instead of clear_soft_dirty
Message-ID: <20140415184851.GS23983@moon>
References: <20140324122838.490106581@openvz.org>
 <20140324125926.204897920@openvz.org>
 <20140415110654.4dd9a97c216e2689316fa448@linux-foundation.org>
 <20140415182935.GR23983@moon>
 <20140415114449.c8732a56f9974c2819e4541a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140415114449.c8732a56f9974c2819e4541a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, xemul@parallels.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Tue, Apr 15, 2014 at 11:44:49AM -0700, Andrew Morton wrote:
> On Tue, 15 Apr 2014 22:29:35 +0400 Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> 
> > On Tue, Apr 15, 2014 at 11:06:54AM -0700, Andrew Morton wrote:
> > > 
> > > I resolved this by merging
> > > mm-softdirty-clear-vm_softdirty-flag-inside-clear_refs_write-instead-of-clear_soft_dirty.patch
> > > on top of the pagewalk patches as below - please carefully review.
> > 
> > Thanks a lot, Andrew! I've updated the patches and were planning to send them to you
> > tonightm but because you applied it on top of pagewal patches, I think i rather need to
> > fetch -next repo and review this patch and update the rest of the series on top (hope
> > i'll do that in 3-4 hours).
> 
> -mm isn't in -next at present.  I'll get a release done later today for
> tomorrow's -next.

OK. Could you please remind me the place I could fetch the patchwalk series from?
(or better to wait until -mm get merged into -next?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
