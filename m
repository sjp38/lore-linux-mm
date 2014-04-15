Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5070F6B0036
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 14:29:39 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id ec20so7220612lab.15
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 11:29:38 -0700 (PDT)
Received: from mail-la0-x236.google.com (mail-la0-x236.google.com [2a00:1450:4010:c03::236])
        by mx.google.com with ESMTPS id pw3si13581941lbb.211.2014.04.15.11.29.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 11:29:37 -0700 (PDT)
Received: by mail-la0-f54.google.com with SMTP id mc6so7272242lab.13
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 11:29:36 -0700 (PDT)
Date: Tue, 15 Apr 2014 22:29:35 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 4/4] mm: Clear VM_SOFTDIRTY flag inside clear_refs_write
 instead of clear_soft_dirty
Message-ID: <20140415182935.GR23983@moon>
References: <20140324122838.490106581@openvz.org>
 <20140324125926.204897920@openvz.org>
 <20140415110654.4dd9a97c216e2689316fa448@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140415110654.4dd9a97c216e2689316fa448@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, xemul@parallels.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Tue, Apr 15, 2014 at 11:06:54AM -0700, Andrew Morton wrote:
> 
> I resolved this by merging
> mm-softdirty-clear-vm_softdirty-flag-inside-clear_refs_write-instead-of-clear_soft_dirty.patch
> on top of the pagewalk patches as below - please carefully review.

Thanks a lot, Andrew! I've updated the patches and were planning to send them to you
tonightm but because you applied it on top of pagewal patches, I think i rather need to
fetch -next repo and review this patch and update the rest of the series on top (hope
i'll do that in 3-4 hours).

> 
> I'm hoping we'll be able to get the pagewalk patches merged in 3.16-rc1
> - we'll see what happens when the testing gets underway again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
