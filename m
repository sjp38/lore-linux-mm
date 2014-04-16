Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 976CB6B0081
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 03:05:24 -0400 (EDT)
Received: by mail-la0-f51.google.com with SMTP id pv20so7715896lab.38
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 00:05:23 -0700 (PDT)
Received: from mail-la0-x232.google.com (mail-la0-x232.google.com [2a00:1450:4010:c03::232])
        by mx.google.com with ESMTPS id sz4si14416690lbb.225.2014.04.16.00.05.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 00:05:22 -0700 (PDT)
Received: by mail-la0-f50.google.com with SMTP id pv20so7625153lab.23
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 00:05:22 -0700 (PDT)
Date: Wed, 16 Apr 2014 11:05:20 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 4/4] mm: Clear VM_SOFTDIRTY flag inside clear_refs_write
 instead of clear_soft_dirty
Message-ID: <20140416070520.GX23983@moon>
References: <20140324122838.490106581@openvz.org>
 <20140324125926.204897920@openvz.org>
 <20140415110654.4dd9a97c216e2689316fa448@linux-foundation.org>
 <20140415182935.GR23983@moon>
 <20140415114449.c8732a56f9974c2819e4541a@linux-foundation.org>
 <20140415184851.GS23983@moon>
 <20140415115219.2676d2107b3f6b0dd5573062@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140415115219.2676d2107b3f6b0dd5573062@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, xemul@parallels.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Tue, Apr 15, 2014 at 11:52:19AM -0700, Andrew Morton wrote:
> > > 
> > > -mm isn't in -next at present.  I'll get a release done later today for
> > > tomorrow's -next.
> > 
> > OK. Could you please remind me the place I could fetch the patchwalk series from?
> 
> http://ozlabs.org/~akpm/mmots/
> 
> > (or better to wait until -mm get merged into -next?)
> 
> That's probably simpler.

I've fetched -next tree and updated patch looks good, thanks Andrew!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
